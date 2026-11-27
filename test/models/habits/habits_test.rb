require "test_helper"

class Habits::HabitsTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.completions.destroy_all
    @monday = Date.new(2026, 5, 4)
  end

  def complete_on(date, task = tasks(:laundry_weekly))
    time = @user.zone.local(date.year, date.month, date.day, 10)
    task.update_columns(next_due_on: nil, deferred_until: nil, completed_at: nil)
    task.complete!(today: date, at: time)
  end

  # --- week progress ---------------------------------------------------------

  test "counts distinct active days this week, Monday to Sunday" do
    complete_on(@monday)
    complete_on(@monday)
    complete_on(@monday + 2)
    week = Habits::WeekProgress.new(@user, today: @monday + 3)
    assert_equal 2, week.active_days
    assert_equal 0, week.wins_today
    assert_equal [ true, false, true, false, false, false, false ], week.days.map { |d| d[:active] }
    assert week.days[3][:today]
    assert_not week.as_json[:met]
  end

  test "four active days meets the weekly goal" do
    4.times { |i| complete_on(@monday + i) }
    assert Habits::WeekProgress.new(@user, today: @monday + 3).as_json[:met]
  end

  test "last week's activity does not count and a new week starts fresh" do
    complete_on(@monday - 2)
    assert_equal 0, Habits::WeekProgress.new(@user, today: @monday).active_days
  end

  test "undone completions do not count" do
    task = tasks(:wipe_counters)
    complete_on(@monday, task)
    task.uncomplete!
    assert_equal 0, Habits::WeekProgress.new(@user, today: @monday).active_days
  end

  test "wins today counts every completion today" do
    complete_on(@monday)
    complete_on(@monday, tasks(:wipe_counters))
    assert_equal 2, Habits::WeekProgress.new(@user, today: @monday).wins_today
  end

  # --- fresh start -----------------------------------------------------------

  test "welcome back takes priority" do
    result = Habits::FreshStart.call(@user, today: @monday, welcome_back: true, wins_today: 0)
    assert_equal "welcome_back", result[:kind]
  end

  test "mondays and the first of the month are fresh starts" do
    assert_equal "new_week", Habits::FreshStart.call(@user, today: @monday, welcome_back: false, wins_today: 0)[:kind]
    assert_equal "new_month", Habits::FreshStart.call(@user, today: Date.new(2026, 6, 1), welcome_back: false, wins_today: 0)[:kind]
  end

  test "a quiet yesterday gets a kind nudge, never a penalty" do
    complete_on(@monday)
    result = Habits::FreshStart.call(@user, today: @monday + 2, welcome_back: false, wins_today: 0)
    assert_equal "tiny_win", result[:kind]
    assert_no_match(/miss|lost|streak|failed/i, result[:message])
  end

  test "no nudge when yesterday was active, today already has a win, or there is no history" do
    complete_on(@monday)
    assert_nil Habits::FreshStart.call(@user, today: @monday + 1, welcome_back: false, wins_today: 0)
    assert_nil Habits::FreshStart.call(@user, today: @monday + 2, welcome_back: false, wins_today: 1)
    @user.completions.reload.destroy_all
    assert_nil Habits::FreshStart.call(@user, today: @monday + 2, welcome_back: false, wins_today: 0)
  end

  # --- messages --------------------------------------------------------------

  test "identity message names the room kept calm" do
    complete_on(@monday, tasks(:wipe_counters))
    complete_on(@monday + 1, tasks(:wipe_counters))
    week = Habits::WeekProgress.new(@user, today: @monday + 2)
    assert_equal "You've kept the kitchen calm 2 times this week.", Habits::Messages.identity(@user, week)
  end

  test "identity message falls back kindly" do
    week = Habits::WeekProgress.new(@user, today: @monday)
    assert_equal "Every small win builds a calmer home.", Habits::Messages.identity(@user, week)
  end

  test "victory messages are deterministic, not random" do
    task = tasks(:wipe_counters)
    completion = Completion.new(id: 7)
    a = Habits::Messages.victory(task: task, completion: completion, first: false, leveled_up: false)
    b = Habits::Messages.victory(task: task, completion: completion, first: false, leveled_up: false)
    assert_equal a, b
    assert_match(/Counter Goblins|Crumbs/, a)
  end

  test "the first victory and level ups have their own messages" do
    task = tasks(:wipe_counters)
    completion = Completion.new(id: 1)
    assert_match(/first quest/, Habits::Messages.victory(task: task, completion: completion, first: true, leveled_up: false))
    assert_match(/Level up/, Habits::Messages.victory(task: task, completion: completion, first: false, leveled_up: true))
  end

  # --- one thing today -------------------------------------------------------

  test "the one thing is an available task and honours exclusions" do
    today = @user.today
    pick = Habits::TodayPicker.new(user: @user, today: today).call
    assert pick.task.available_on?(today)
    other = Habits::TodayPicker.new(user: @user, today: today, exclude: [ pick.task.id ]).call
    assert_not_equal pick.task, other.task
  end

  test "a committed intention wins over the recommender" do
    today = @user.today
    chosen = tasks(:laundry_weekly)
    @user.daily_intentions.create!(task: chosen, on_date: today, anchor: "after dinner")
    pick = Habits::TodayPicker.new(user: @user, today: today).call
    assert_equal chosen, pick.task
    assert_equal "after dinner", pick.intention.anchor
  end

  test "asking for easier steps the energy down" do
    pick = Habits::TodayPicker.new(user: @user, today: @user.today, energy: "hero", easier: true).call
    assert_equal "ready", pick.energy
  end

  test "no available tasks yields no pick, not an error" do
    @user.tasks.destroy_all
    assert_nil Habits::TodayPicker.new(user: @user, today: @user.today).call.task
  end
end

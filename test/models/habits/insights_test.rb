require "test_helper"

class Habits::InsightsTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.tasks.destroy_all
    @user.completions.reload.destroy_all
    @monday = Date.new(2026, 5, 4)
    @wednesday = @monday + 2
  end

  def task(title = "Wipe", room: "kitchen", minutes: 5)
    @user.tasks.create!(title: title, room: room, duration_minutes: minutes, effort: "tiny",
                        recurrence_kind: "completion", recurrence_interval_days: 1)
  end

  def finish(task, on:)
    task.update_columns(next_due_on: nil, deferred_until: nil, completed_at: nil)
    task.complete!(today: on, at: @user.zone.local(on.year, on.month, on.day, 9))
  end

  def insights(today: @wednesday)
    Habits::Insights.call(@user, today: today)
  end

  test "a blank week is described kindly" do
    assert_equal 0, insights[:this_week][:quests]
    assert_match(/blank page/, insights[:message])
  end

  test "counts this week's quests, days and quick wins" do
    t = task
    finish(t, on: @monday)
    finish(t, on: @monday)
    finish(t, on: @wednesday)
    stats = insights[:this_week]
    assert_equal 3, stats[:quests]
    assert_equal 2, stats[:active_days]
    assert_equal 3, stats[:quick_wins]
    assert_equal "kitchen", stats[:top_room]
    assert_equal "Monday", stats[:busiest_day]
  end

  test "weeks run Monday to Sunday and are kept separate" do
    t = task
    finish(t, on: @monday - 1) # Sunday of last week
    finish(t, on: @monday)     # Monday of this week
    result = insights
    assert_equal 1, result[:this_week][:quests]
    assert_equal 1, result[:last_week][:quests]
  end

  test "returns four weeks oldest first, ending with this week" do
    weeks = insights[:weeks]
    assert_equal 4, weeks.size
    assert_equal "This week", weeks.last[:label]
    assert_equal "Last week", weeks[-2][:label]
  end

  test "xp includes everything earned in the week" do
    finish(task, on: @wednesday)
    travel_to @user.zone.local(@wednesday.year, @wednesday.month, @wednesday.day, 12) do
      Game::AwardOneOff.call(user: @user, kind: "start", reference: "z:1", xp: 3)
      assert_operator insights[:this_week][:xp], :>=, 3
    end
  end

  test "to-dos and boss stages are counted" do
    todo = @user.todos.create!(title: "x")
    todo.update!(completed_at: @user.zone.local(@wednesday.year, @wednesday.month, @wednesday.day, 10))
    assert_equal 1, insights[:this_week][:todos_done]
  end

  test "messages: steady, lighter, fresh start and quiet are all encouraging" do
    t = task
    finish(t, on: @monday - 3)
    finish(t, on: @monday - 2)
    finish(t, on: @monday)
    assert_match(/fresh|steady|Lovely|lighter/i, insights[:message])
    assert_match(/lighter week.*that's fine/i, insights[:message])

    finish(t, on: @monday + 1)
    finish(t, on: @monday + 2)
    assert_match(/steady rhythm/, insights[:message])
  end

  test "a quiet week after an active one is rest, not failure" do
    t = task
    finish(t, on: @monday - 3)
    assert_match(/quiet week.*fine/i, insights(today: @monday)[:message])
    assert_no_match(/fail|worse|behind|missed/i, insights(today: @monday)[:message])
  end

  test "a first active week reads as a fresh start" do
    finish(task, on: @wednesday)
    assert_match(/fresh start/i, insights[:message])
  end

  test "other players' activity is never included" do
    other = users(:two)
    other.tasks.create!(title: "x", room: "kitchen").tap { |t| t.complete!(today: @wednesday, at: other.zone.local(2026, 5, 6, 9)) }
    assert_equal 0, insights[:this_week][:quests]
  end

  test "Sunday and Monday get a link to the insights page" do
    sunday = @monday + 6
    assert_equal "week_review", Habits::FreshStart.call(@user, today: sunday, welcome_back: false, wins_today: 1)[:kind]
    assert_equal "/insights", Habits::FreshStart.call(@user, today: @monday, welcome_back: false, wins_today: 1)[:link][:href]
  end
end

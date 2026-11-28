require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @today = Date.new(2026, 5, 6) # a Wednesday
  end

  def build(**attrs)
    @user.tasks.build({ title: "Do thing" }.merge(attrs))
  end

  test "defaults to a small, active, non-repeating task" do
    task = @user.tasks.create!(title: "New")
    assert_equal "small", task.effort
    assert_equal "active", task.status
    assert_equal "none", task.recurrence_kind
    assert_nil task.next_due_on
  end

  test "requires a title" do
    assert_not build(title: " ").valid?
  end

  test "validates enums and duration" do
    assert_not build(room: "attic").valid?
    assert_not build(effort: "huge").valid?
    assert_not build(duration_minutes: 0).valid?
    assert_not build(duration_minutes: 500).valid?
  end

  test "calendar recurrence needs weekdays" do
    assert_not build(recurrence_kind: "calendar", recurrence_weekdays: []).valid?
    assert build(recurrence_kind: "calendar", recurrence_weekdays: [ 4 ]).valid?
  end

  test "completion recurrence needs an interval" do
    assert_not build(recurrence_kind: "completion").valid?
    assert build(recurrence_kind: "completion", recurrence_interval_days: 7).valid?
  end

  test "calendar task starts on its next matching weekday" do
    task = build(recurrence_kind: "calendar", recurrence_weekdays: [ 4 ])
    task.save!
    assert_equal 4, task.next_due_on.wday
    assert task.next_due_on >= @user.today
  end

  test "completing a one-off task finishes it exactly once" do
    task = tasks(:wipe_counters)
    assert_difference -> { Completion.count }, 1 do
      assert task.complete!(today: @today)
      assert_nil task.complete!(today: @today)
    end
    assert task.reload.completed_at
    assert_not task.available_on?(@today)
  end

  test "completing a completion-based task schedules the next one N days later" do
    task = tasks(:laundry_weekly)
    task.complete!(today: @today)
    assert_equal @today + 7, task.reload.next_due_on
    assert_not task.available_on?(@today)
    assert task.available_on?(@today + 7)
  end

  test "completing a calendar task never lands on the same due date" do
    task = build(recurrence_kind: "calendar", recurrence_weekdays: [ 4 ])
    task.save!
    task.update_columns(next_due_on: Date.new(2026, 5, 7)) # Thursday
    assert_nil task.complete!(today: @today), "not available before its due date"
    task.complete!(today: Date.new(2026, 5, 8)) # finished a day late, Friday
    assert_equal Date.new(2026, 5, 14), task.reload.next_due_on
  end

  test "undo restores a one-off task" do
    task = tasks(:wipe_counters)
    task.complete!(today: @today)
    assert task.uncomplete!
    assert_nil task.reload.completed_at
    assert task.available_on?(@today)
    assert_nil task.uncomplete!
  end

  test "undo restores a recurring task's previous due date" do
    task = tasks(:laundry_weekly)
    task.complete!(today: @today)
    task.uncomplete!
    assert_nil task.reload.next_due_on
    assert Completion.where(task: task).all?(&:undone?)
  end

  test "skip moves recurring tasks on without a completion" do
    task = tasks(:laundry_weekly)
    assert_no_difference -> { Completion.count } do
      task.skip!(today: @today)
    end
    assert_equal @today + 7, task.reload.next_due_on
  end

  test "skip brings a one-off task back tomorrow" do
    task = tasks(:wipe_counters)
    task.skip!(today: @today)
    assert_not task.reload.available_on?(@today)
    assert task.available_on?(@today + 1)
  end

  test "defer hides a task until the given date" do
    task = tasks(:wipe_counters)
    task.defer!(until_date: @today + 3)
    assert_not task.available_on?(@today + 2)
    assert task.available_on?(@today + 3)
  end

  test "missed recurring tasks do not create extra copies" do
    task = tasks(:laundry_weekly)
    assert_no_difference -> { Task.count } do
      task.skip!(today: @today)
      task.skip!(today: @today + 30)
    end
  end

  test "picks a default monster and fantasy title from the room" do
    task = tasks(:wipe_counters)
    assert_equal "counter_goblins", task.monster_key_or_default
    assert_equal "Banish the Counter Goblins", task.fantasy_title_or_default
  end

  test "rewards come from the economy config by effort" do
    assert_equal 15, tasks(:wipe_counters).xp
    assert_equal 8, tasks(:wipe_counters).coins
  end

  test "is destroyed with its user" do
    assert_difference -> { Task.count }, -users(:one).tasks.count do
      users(:one).destroy
    end
  end
end

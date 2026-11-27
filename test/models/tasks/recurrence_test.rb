require "test_helper"

class Tasks::RecurrenceTest < ActiveSupport::TestCase
  def task(kind, weekdays: [], interval: nil, next_due_on: nil)
    Task.new(recurrence_kind: kind, recurrence_weekdays: weekdays,
             recurrence_interval_days: interval, next_due_on: next_due_on)
  end

  test "initial due date is the next matching weekday, today included" do
    wednesday = Date.new(2026, 5, 6)
    assert_equal wednesday, Tasks::Recurrence.initial_due_on(task("calendar", weekdays: [ 3 ]), wednesday)
    assert_equal Date.new(2026, 5, 7), Tasks::Recurrence.initial_due_on(task("calendar", weekdays: [ 4 ]), wednesday)
  end

  test "non-calendar tasks have no initial due date" do
    assert_nil Tasks::Recurrence.initial_due_on(task("none"), Date.today)
    assert_nil Tasks::Recurrence.initial_due_on(task("completion", interval: 3), Date.today)
  end

  test "daily calendar task is due tomorrow after completion" do
    daily = task("calendar", weekdays: (0..6).to_a)
    assert_equal Date.new(2026, 5, 7), Tasks::Recurrence.next_due_on(daily, Date.new(2026, 5, 6))
  end

  test "calendar task finished late moves to the next weekday after today" do
    thursday = task("calendar", weekdays: [ 4 ], next_due_on: Date.new(2026, 5, 7))
    assert_equal Date.new(2026, 5, 14), Tasks::Recurrence.next_due_on(thursday, Date.new(2026, 5, 11))
  end

  test "completion-based task counts from the completion date" do
    assert_equal Date.new(2026, 5, 13), Tasks::Recurrence.next_due_on(task("completion", interval: 7), Date.new(2026, 5, 6))
  end

  test "one-off tasks have no next date" do
    assert_nil Tasks::Recurrence.next_due_on(task("none"), Date.today)
  end
end

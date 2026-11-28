require "test_helper"

class RoutineTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @routine = @user.routines.create!(name: "Evening reset", weekdays: [ 1, 3 ])
  end

  test "requires a name" do
    assert_not @user.routines.build(name: " ").valid?
  end

  test "weekdays must be valid days" do
    assert_not @user.routines.build(name: "x", weekdays: [ 9 ]).valid?
  end

  test "an empty schedule means every day" do
    every = @user.routines.create!(name: "Daily")
    assert every.scheduled_on?(Date.new(2026, 5, 6))
    assert every.scheduled_on?(Date.new(2026, 5, 9))
  end

  test "scheduled only on its weekdays" do
    assert @routine.scheduled_on?(Date.new(2026, 5, 4)) # Monday
    assert_not @routine.scheduled_on?(Date.new(2026, 5, 5)) # Tuesday
  end

  test "replace_steps! creates, reorders and removes steps while keeping history" do
    @routine.replace_steps!([ { title: "A" }, { title: "B" }, { title: "C" } ])
    a, b, c = @routine.steps.reload.to_a
    RoutineStepCompletion.create!(routine_step: a, on_date: Date.today)

    @routine.replace_steps!([ { id: c.id, title: "C" }, { id: a.id, title: "A renamed" } ])
    steps = @routine.steps.reload
    assert_equal [ "C", "A renamed" ], steps.map(&:title)
    assert_nil RoutineStep.find_by(id: b.id)
    assert_equal 1, a.completions.count
  end

  test "a step can link to the user's task and defaults its title" do
    task = tasks(:wipe_counters)
    @routine.replace_steps!([ { title: "", task_id: task.id } ])
    assert_equal task.title, @routine.steps.first.title
  end

  test "cannot link another user's task" do
    assert_raises(ActiveRecord::RecordNotFound) do
      @routine.replace_steps!([ { title: "x", task_id: tasks(:other_users_task).id } ])
    end
  end
end

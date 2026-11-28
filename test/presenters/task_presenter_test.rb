require "test_helper"

class TaskPresenterTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.tasks.destroy_all
    @task = @user.tasks.create!(title: "Wipe sides", recurrence_kind: "completion", recurrence_interval_days: 1)
  end

  def json
    TaskPresenter.new(@task, today: @user.today, last_done: TaskPresenter.last_done_map([ @task ])[@task.id]).as_json
  end

  test "a chore never done has no last-done date" do
    assert_nil json[:last_done_days]
  end

  test "reports whole days since it was last done" do
    @task.complete!(today: @user.today, at: 3.days.ago)
    assert_equal 3, json[:last_done_days]
  end

  test "an undone completion does not count" do
    @task.complete!(today: @user.today, at: 3.days.ago)
    @task.uncomplete!
    assert_nil json[:last_done_days]
  end
end

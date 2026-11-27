require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @task = tasks(:wipe_counters)
    @weekly = tasks(:laundry_weekly)
  end

  test "requires authentication" do
    post tasks_path, params: { title: "x" }
    assert_redirected_to login_path
  end

  test "creates a task for the current user" do
    log_in_as(@user)
    assert_difference -> { @user.tasks.count }, 1 do
      post tasks_path, params: { title: "Water plants", room: "garden", effort: "tiny", duration_minutes: 4 }
    end
    assert_redirected_to quests_path
    assert_equal "garden", @user.tasks.find_by!(title: "Water plants").room
  end

  test "creates a calendar-recurring task" do
    log_in_as(@user)
    post tasks_path, params: { title: "PE kit", recurrence_kind: "calendar", recurrence_weekdays: [ "4" ] }
    task = @user.tasks.find_by!(title: "PE kit")
    assert_equal [ 4 ], task.recurrence_weekdays
    assert_equal 4, task.next_due_on.wday
  end

  test "rejects an invalid task" do
    log_in_as(@user)
    assert_no_difference -> { Task.count } do
      post tasks_path, params: { title: "", duration_minutes: 0 }
    end
    assert_response :redirect
  end

  test "edits a task" do
    log_in_as(@user)
    patch task_path(@task), params: { title: "Wipe all worktops", duration_minutes: 8 }
    assert_equal "Wipe all worktops", @task.reload.title
    assert_equal 8, @task.duration_minutes
  end

  test "completes and undoes a task" do
    log_in_as(@user)
    assert_difference -> { Completion.count }, 1 do
      post complete_task_path(@task)
    end
    assert_response :redirect
    assert @task.reload.completed_at
    post uncomplete_task_path(@task)
    assert_nil @task.reload.completed_at
  end

  test "completing twice records only one completion" do
    log_in_as(@user)
    assert_difference -> { Completion.count }, 1 do
      2.times { post complete_task_path(@task) }
    end
  end

  test "skip and defer never create completions" do
    log_in_as(@user)
    assert_no_difference -> { Completion.count } do
      post skip_task_path(@weekly)
      post defer_task_path(@task), params: { days: 2 }
    end
    assert_not @task.reload.available_on?(@user.today)
  end

  test "deleting a task with no history removes it" do
    log_in_as(@user)
    assert_difference -> { Task.count }, -1 do
      delete task_path(@task)
    end
  end

  test "deleting a task with history archives it" do
    log_in_as(@user)
    post complete_task_path(@weekly)
    assert_no_difference -> { Task.count } do
      delete task_path(@weekly)
    end
    assert_equal "archived", @weekly.reload.status
  end

  test "cannot touch another user's task" do
    log_in_as(@user)
    other = tasks(:other_users_task)
    patch task_path(other), params: { title: "hacked" }
    assert_response :not_found
    post complete_task_path(other)
    assert_response :not_found
    delete task_path(other)
    assert_response :not_found
    assert_equal "Not yours", other.reload.title
  end
end

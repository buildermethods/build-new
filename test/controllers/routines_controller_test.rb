require "test_helper"

class RoutinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @routine = @user.routines.create!(name: "Morning")
    @routine.replace_steps!([ { title: "Brush teeth" }, { title: "Pack bags" } ])
  end

  test "requires authentication" do
    get routines_path
    assert_redirected_to login_path
  end

  test "lists only my routines" do
    users(:two).routines.create!(name: "Not mine")
    log_in_as(@user)
    get routines_path
    assert_includes response.body, "Morning"
    assert_not_includes response.body, "Not mine"
  end

  test "creates a routine with ordered steps" do
    log_in_as(@user)
    assert_difference -> { @user.routines.count }, 1 do
      post routines_path, params: { name: "Evening", weekdays: [ "1", "2" ], steps: [ { title: "Dishes" }, { title: "Lights off" } ] }
    end
    routine = @user.routines.find_by!(name: "Evening")
    assert_equal [ "Dishes", "Lights off" ], routine.steps.map(&:title)
    assert_equal [ 1, 2 ], routine.weekdays
  end

  test "rejects a routine without a name" do
    log_in_as(@user)
    assert_no_difference -> { Routine.count } do
      post routines_path, params: { name: "", steps: [ { title: "x" } ] }
    end
  end

  test "updates a routine, keeping step history" do
    log_in_as(@user)
    step = @routine.steps.first
    RoutineStepCompletion.create!(routine_step: step, on_date: @user.today)
    patch routine_path(@routine), params: { name: "Morning v2", steps: [ { id: step.id, title: "Teeth" } ] }
    assert_equal "Morning v2", @routine.reload.name
    assert_equal [ "Teeth" ], @routine.steps.reload.map(&:title)
    assert_equal 1, step.completions.count
  end

  test "deletes a routine" do
    log_in_as(@user)
    assert_difference -> { Routine.count }, -1 do
      delete routine_path(@routine)
    end
  end

  test "cannot touch another user's routine" do
    other = users(:two).routines.create!(name: "Theirs")
    log_in_as(@user)
    patch routine_path(other), params: { name: "hacked" }
    assert_response :not_found
    delete routine_path(other)
    assert_response :not_found
    post complete_all_routine_path(other)
    assert_response :not_found
  end

  test "cannot link a step to another user's task" do
    log_in_as(@user)
    post routines_path, params: { name: "X", steps: [ { title: "s", task_id: tasks(:other_users_task).id } ] }
    assert_response :not_found
  end

  test "ticks and unticks a step" do
    log_in_as(@user)
    step = @routine.steps.first
    post complete_routine_step_path(@routine, step)
    assert_equal 1, step.completions.count
    delete uncomplete_routine_step_path(@routine, step)
    assert_equal 0, step.completions.count
  end

  test "complete all awards the bonus once and shows a victory" do
    log_in_as(@user)
    post complete_all_routine_path(@routine)
    assert_equal 20, PlayerProgress.find_by!(user: @user).xp
    follow_redirect!
    assert_includes response.body, "Routine complete"
    post complete_all_routine_path(@routine)
    assert_equal 20, PlayerProgress.find_by!(user: @user).xp
  end

  test "cannot tick another user's step" do
    other = users(:two).routines.create!(name: "Theirs")
    other.replace_steps!([ { title: "x" } ])
    log_in_as(@user)
    post complete_routine_step_path(other, other.steps.first)
    assert_response :not_found
  end

  test "complete all sums the XP of every linked task plus the bonus" do
    log_in_as(@user)
    t1 = @user.tasks.create!(title: "Linked one", effort: "tiny", duration_minutes: 3)
    t2 = @user.tasks.create!(title: "Linked two", effort: "tiny", duration_minutes: 3)
    @routine.replace_steps!([ { title: "A", task_id: t1.id }, { title: "B", task_id: t2.id } ])
    post complete_all_routine_path(@routine)
    expected = Game::Economy.xp_for("tiny") * 2 + Game::Economy.routine_bonus[:xp]
    assert_equal expected, flash[:victory][:xp]
    assert_equal expected, PlayerProgress.find_by!(user: @user).xp
  end
end

require "test_helper"

class HabitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @task = tasks(:wipe_counters)
  end

  def xp
    PlayerProgress.find_by!(user: @user).xp
  end

  # --- starting counts -------------------------------------------------------

  test "starting a task awards a small one-off xp, once per task per day" do
    log_in_as(@user)
    post start_task_path(@task)
    assert_equal 3, xp
    post start_task_path(@task)
    assert_equal 3, xp
    assert_equal 1, RewardTransaction.where(kind: "start").count
  end

  test "start answers with JSON and never sets a flash" do
    log_in_as(@user)
    post start_task_path(@task), as: :json
    assert_response :success
    assert_equal({ "awarded" => true, "xp" => 3 }, response.parsed_body)
    assert_nil flash[:notice]
    post start_task_path(@task), as: :json
    assert_equal false, response.parsed_body["awarded"]
  end

  test "starting a different task awards separately" do
    log_in_as(@user)
    post start_task_path(@task)
    post start_task_path(tasks(:laundry_weekly))
    assert_equal 6, xp
  end

  test "cannot start another user's task" do
    log_in_as(@user)
    post start_task_path(tasks(:other_users_task))
    assert_response :not_found
  end

  test "start requires authentication" do
    post start_task_path(@task)
    assert_redirected_to login_path
  end

  # --- intentions ------------------------------------------------------------

  test "plans when to do a task, one per day, replacing the earlier choice" do
    log_in_as(@user)
    post intentions_path, params: { task_id: @task.id, anchor: "after dinner" }
    post intentions_path, params: { task_id: tasks(:laundry_weekly).id, anchor: "after lunch" }
    intentions = @user.daily_intentions.where(on_date: @user.today)
    assert_equal 1, intentions.count
    assert_equal tasks(:laundry_weekly), intentions.first.task
    assert_equal "after lunch", intentions.first.anchor
  end

  test "rejects an unknown anchor and another user's task" do
    log_in_as(@user)
    post intentions_path, params: { task_id: @task.id, anchor: "at midnight" }
    assert_equal 0, @user.daily_intentions.count
    post intentions_path, params: { task_id: tasks(:other_users_task).id }
    assert_response :not_found
  end

  test "an intention can be cleared" do
    log_in_as(@user)
    post intentions_path, params: { task_id: @task.id }
    delete intentions_path
    assert_equal 0, @user.daily_intentions.count
  end

  # --- victory ---------------------------------------------------------------

  test "the first victory carries a warm message and the first badge" do
    log_in_as(@user)
    post complete_task_path(@task)
    follow_redirect!
    assert_includes response.body, "Your very first quest"
    assert_includes response.body, "First Victory"
  end

  test "badges are earned once and listed on Today" do
    log_in_as(@user)
    post complete_task_path(@task)
    post complete_task_path(tasks(:laundry_weekly))
    assert_equal 1, @user.user_achievements.where(key: "first_victory").count
    get root_path
    assert_includes response.body, "First Victory"
  end

  test "the welcome bonus is given once with onboarding" do
    user = users(:two)
    user.update!(onboarded_at: nil)
    draft = Onboarding::Draft.new(user)
    Onboarding::Complete.call(user: user, draft: draft)
    assert_equal 20, PlayerProgress.find_by!(user: user).xp
    assert_equal 1, RewardTransaction.where(user: user, kind: "welcome").count
  end
end

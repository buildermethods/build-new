require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "requires authentication" do
    post claim_challenge_path("daily")
    assert_redirected_to login_path
  end

  test "Today shows a daily and a weekly challenge" do
    log_in_as(@user)
    get root_path
    assert_includes response.body, "&quot;period&quot;:&quot;daily&quot;"
    assert_includes response.body, "&quot;period&quot;:&quot;weekly&quot;"
  end

  test "an incomplete challenge cannot be claimed" do
    log_in_as(@user)
    post claim_challenge_path("daily")
    assert_redirected_to root_path
    assert_match(/Not quite there yet/, flash[:alert])
    assert_equal 0, RewardTransaction.where(kind: "challenge").count
  end

  test "an unknown period is rejected" do
    log_in_as(@user)
    post claim_challenge_path("yearly")
    assert_match(/doesn't exist/, flash[:alert])
  end

  test "a completed challenge is claimed once" do
    log_in_as(@user)
    challenge = Challenges::Current.call(@user).first
    config = Game::Catalog.challenges["daily"].find { |c| c["key"] == challenge[:key].split(":").last }
    if config["metric"] == "starts"
      post start_task_path(tasks(:wipe_counters))
    else
      room = config["metric"].start_with?("room:") ? config["metric"].split(":").last : "kitchen"
      config["target"].times do |i|
        task = @user.tasks.create!(title: "Q#{i}", duration_minutes: 3, room: room, effort: "tiny")
        post complete_task_path(task)
      end
    end
    post claim_challenge_path("daily")
    assert_match(/Challenge complete/, flash[:notice])
    post claim_challenge_path("daily")
    assert_match(/already claimed/, flash[:alert])
    assert_equal 1, RewardTransaction.where(kind: "challenge").count
  end
end

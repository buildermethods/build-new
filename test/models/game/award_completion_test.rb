require "test_helper"

class Game::AwardCompletionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @today = Date.new(2026, 5, 6)
  end

  test "completing a task awards xp and coins once" do
    task = tasks(:wipe_counters) # tiny: 15 xp, 8 coins
    completion = task.complete!(today: @today)

    assert completion.reward.awarded
    progress = @user.reload.progress
    assert_equal 15, progress.xp
    assert_equal 8, progress.coins
    assert_equal 1, RewardTransaction.where(completion: completion, kind: "completion").count
  end

  test "calling the award twice for the same completion does nothing the second time" do
    completion = tasks(:wipe_counters).complete!(today: @today)

    second = Game::AwardCompletion.call(completion)
    assert_not second.awarded
    assert_equal 15, @user.reload.progress.xp
    assert_equal 1, RewardTransaction.where(completion: completion).count
  end

  test "the database refuses a duplicate reward row" do
    completion = tasks(:wipe_counters).complete!(today: @today)
    assert_raises(ActiveRecord::RecordNotUnique) do
      RewardTransaction.create!(user: @user, completion: completion, kind: "completion", xp_delta: 1, coin_delta: 1)
    end
  end

  test "skip and defer award nothing" do
    tasks(:laundry_weekly).skip!(today: @today)
    tasks(:wipe_counters).defer!(until_date: @today + 1)
    assert_equal 0, @user.reload.progress.xp
    assert_equal 0, RewardTransaction.count
  end

  test "reports a level up" do
    progress = @user.progress
    progress.update!(xp: 90)
    completion = tasks(:wipe_counters).complete!(today: @today)

    assert completion.reward.leveled_up?
    assert_equal 2, completion.reward.to_level
  end

  test "recurring tasks reward every real completion" do
    task = tasks(:laundry_weekly)
    task.complete!(today: @today)
    task.complete!(today: @today + 7)
    assert_equal 30, @user.reload.progress.xp
    assert_equal 2, RewardTransaction.where(kind: "completion").count
  end
end

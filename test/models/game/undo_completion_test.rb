require "test_helper"

class Game::UndoCompletionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @today = Date.new(2026, 5, 6)
  end

  test "undoing a completion reverses its xp and coins" do
    task = tasks(:wipe_counters)
    task.complete!(today: @today)
    task.uncomplete!

    progress = @user.reload.progress
    assert_equal 0, progress.xp
    assert_equal 0, progress.coins
    assert_equal %w[completion reversal], RewardTransaction.order(:id).pluck(:kind)
  end

  test "undo is applied once" do
    task = tasks(:wipe_counters)
    completion = task.complete!(today: @today)
    task.uncomplete!

    assert_nil Game::UndoCompletion.call(completion)
    assert_equal 0, @user.reload.progress.xp
    assert_equal 1, RewardTransaction.where(kind: "reversal").count
  end

  test "completing again after an undo awards again" do
    task = tasks(:wipe_counters)
    task.complete!(today: @today)
    task.uncomplete!
    task.complete!(today: @today)
    assert_equal 15, @user.reload.progress.xp
  end

  test "coins already spent are not driven below zero" do
    task = tasks(:wipe_counters) # 8 coins
    task.complete!(today: @today)
    @user.progress.update!(coins: 3)
    task.uncomplete!

    assert_equal 0, @user.reload.progress.coins
    assert_equal(-3, RewardTransaction.find_by(kind: "reversal").coin_delta)
  end

  test "totals always equal the sum of the ledger" do
    task = tasks(:laundry_weekly)
    task.complete!(today: @today)
    task.uncomplete!
    task.complete!(today: @today)
    progress = @user.reload.progress
    assert_equal RewardTransaction.where(user: @user).sum(:xp_delta), progress.xp
    assert_equal RewardTransaction.where(user: @user).sum(:coin_delta), progress.coins
  end
end

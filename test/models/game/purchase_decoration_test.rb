require "test_helper"

class Game::PurchaseDecorationTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.progress.update!(coins: 100)
  end

  def buy(key)
    Game::PurchaseDecoration.call(user: @user, key: key)
  end

  test "buying spends coins, records ownership and a ledger entry" do
    result = buy("fern_pot") # 20 coins
    assert result.ok?
    assert_equal 80, @user.reload.progress.coins
    assert @user.owned_decorations.exists?(decoration_key: "fern_pot")
    tx = RewardTransaction.find_by!(kind: "purchase")
    assert_equal(-20, tx.coin_delta)
    assert_equal "fern_pot", tx.reference
    assert_nil tx.completion_id
  end

  test "cannot buy without enough coins" do
    result = buy("starry_rug") # 120 coins
    assert_not result.ok?
    assert_equal :insufficient_coins, result.error
    assert_equal 100, @user.reload.progress.coins
    assert_empty @user.owned_decorations
  end

  test "can spend down to exactly zero" do
    @user.progress.update!(coins: 20)
    assert buy("fern_pot").ok?
    assert_equal 0, @user.reload.progress.coins
  end

  test "buying the same item twice charges once" do
    assert buy("fern_pot").ok?
    second = buy("fern_pot")
    assert_equal :already_owned, second.error
    assert_equal 80, @user.reload.progress.coins
    assert_equal 1, RewardTransaction.where(kind: "purchase").count
  end

  test "the database refuses a duplicate purchase row" do
    buy("fern_pot")
    assert_raises(ActiveRecord::RecordNotUnique) do
      RewardTransaction.create!(user: @user, kind: "purchase", reference: "fern_pot", coin_delta: -20)
    end
  end

  test "unknown items are rejected" do
    assert_equal :unknown, buy("jetpack").error
    assert_equal 100, @user.reload.progress.coins
  end

  test "other users are unaffected" do
    buy("fern_pot")
    assert_empty users(:two).owned_decorations
  end
end

require "test_helper"

class Sanctuary::EquipTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.progress.update!(coins: 500)
    Game::PurchaseDecoration.call(user: @user, key: "fern_pot")
    Game::PurchaseDecoration.call(user: @user, key: "lemon_tree")
    Game::PurchaseDecoration.call(user: @user, key: "table_lamp")
  end

  test "equips an owned decoration into its slot" do
    assert Sanctuary::Equip.call(user: @user, key: "fern_pot")
    assert_equal({ "plant" => "fern_pot" }, @user.sanctuary_placements.pluck(:slot, :decoration_key).to_h)
  end

  test "equipping another item in the same slot replaces it" do
    Sanctuary::Equip.call(user: @user, key: "fern_pot")
    Sanctuary::Equip.call(user: @user, key: "lemon_tree")
    assert_equal [ "lemon_tree" ], @user.sanctuary_placements.where(slot: "plant").pluck(:decoration_key)
  end

  test "different slots hold different items" do
    Sanctuary::Equip.call(user: @user, key: "fern_pot")
    Sanctuary::Equip.call(user: @user, key: "table_lamp")
    assert_equal 2, @user.sanctuary_placements.count
  end

  test "cannot equip an item that is not owned" do
    assert_not Sanctuary::Equip.call(user: @user, key: "starry_rug")
    assert_empty @user.sanctuary_placements.where(slot: "rug").reload
  end

  test "cannot equip an unknown item" do
    assert_not Sanctuary::Equip.call(user: @user, key: "jetpack")
  end

  test "another user's item cannot be equipped" do
    assert_not Sanctuary::Equip.call(user: users(:two), key: "fern_pot")
  end

  test "clear empties a slot" do
    Sanctuary::Equip.call(user: @user, key: "fern_pot")
    Sanctuary::Equip.clear(user: @user, slot: "plant")
    assert_empty @user.sanctuary_placements.reload
  end

  test "a placement must match its slot" do
    placement = @user.sanctuary_placements.build(slot: "rug", decoration_key: "fern_pot")
    assert_not placement.valid?
  end
end

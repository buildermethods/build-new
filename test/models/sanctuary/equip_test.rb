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

  # --- rooms ---------------------------------------------------------------------

  def level_up(level)
    @user.progress.update!(xp: Game::Economy.xp_to_reach(level))
  end

  def buy(key)
    @user.progress.update!(coins: @user.progress.coins + 500)
    Game::PurchaseDecoration.call(user: @user, key: key)
  end

  test "the living room is open from the start but other rooms are locked" do
    assert Sanctuary::Equip.unlocked?(@user, "living_room")
    %w[kitchen bedroom garden].each { |r| assert_not Sanctuary::Equip.unlocked?(@user, r), r }
  end

  test "rooms unlock at their levels" do
    level_up(3)
    assert Sanctuary::Equip.unlocked?(@user, "kitchen")
    assert_not Sanctuary::Equip.unlocked?(@user, "bedroom")
    level_up(8)
    assert Sanctuary::Equip.unlocked?(@user, "garden")
  end

  test "cannot place anything in a locked room" do
    assert_not Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "kitchen")
    assert_empty @user.sanctuary_placements.where(room: "kitchen")
  end

  test "an unlocked room accepts a general item and places it there" do
    level_up(3)
    assert Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "kitchen")
    assert_equal "fern_pot", @user.sanctuary_placements.find_by!(room: "kitchen", slot: "plant").decoration_key
  end

  test "room-specific items only fit their room" do
    level_up(8)
    buy("birdhouse")
    assert_not Sanctuary::Equip.call(user: @user, key: "birdhouse", room: "living_room")
    assert Sanctuary::Equip.call(user: @user, key: "birdhouse", room: "garden")
  end

  test "an item is in one place at a time, so equipping elsewhere moves it" do
    level_up(3)
    Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "living_room")
    Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "kitchen")
    assert_equal [ "kitchen" ], @user.sanctuary_placements.where(decoration_key: "fern_pot").pluck(:room)
  end

  test "different rooms hold different items in the same slot" do
    level_up(3)
    Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "living_room")
    buy("herb_pots")
    Sanctuary::Equip.call(user: @user, key: "herb_pots", room: "kitchen")
    assert_equal 2, @user.sanctuary_placements.where(slot: "plant").count
  end

  test "an unknown room is rejected" do
    assert_not Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "attic")
  end

  test "clear empties a slot in one room only" do
    level_up(3)
    Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "kitchen")
    Sanctuary::Equip.clear(user: @user, slot: "plant", room: "living_room")
    assert_equal 1, @user.sanctuary_placements.count
    Sanctuary::Equip.clear(user: @user, slot: "plant", room: "kitchen")
    assert_equal 0, @user.sanctuary_placements.count
  end

  test "rooms stay unlocked even if undoing a quest drops the level" do
    level_up(3)
    assert Sanctuary::Equip.unlocked?(@user, "kitchen")
    @user.progress.update!(xp: 0)
    assert_equal 1, @user.progress.level
    assert Sanctuary::Equip.unlocked?(@user, "kitchen")
    assert Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "kitchen")
  end

  test "the presenter lists rooms, nested placements and where each item is" do
    level_up(3)
    Sanctuary::Equip.call(user: @user, key: "fern_pot", room: "kitchen")
    data = SanctuaryPresenter.new(@user).as_json
    assert_equal %w[living_room kitchen bedroom garden], data[:rooms].map { |r| r[:key] }
    assert_equal [ true, true, false, false ], data[:rooms].map { |r| r[:unlocked] }
    assert_equal({ "kitchen" => { "plant" => "fern_pot" } }, data[:placements])
    assert_equal "kitchen", data[:items].find { |i| i[:key] == "fern_pot" }[:equipped_in]
  end

  test "every decoration is valid and room restrictions name real rooms" do
    Game::Catalog.decorations.each do |key, item|
      assert_includes Game::Catalog.decoration_slots, item["slot"], key
      assert item["price"].positive?, key
      Array(item["rooms"]).each { |r| assert_includes Game::Catalog.cottage_rooms.keys, r, "#{key} names unknown room #{r}" }
    end
    assert_equal 24, Game::Catalog.decorations.size
  end

  test "every room has at least four decorations that fit it" do
    Game::Catalog.cottage_rooms.each_key do |room|
      fitting = Game::Catalog.decorations.select { |_, i| i["rooms"].nil? || i["rooms"].include?(room) }
      assert_operator fitting.size, :>=, 4, room
      assert_equal Game::Catalog.decoration_slots.sort, fitting.values.map { |i| i["slot"] }.uniq.sort, "#{room} lacks a slot type"
    end
  end
end

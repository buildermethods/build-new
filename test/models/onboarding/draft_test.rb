require "test_helper"

class Onboarding::DraftTest < ActiveSupport::TestCase
  setup do
    @user = users(:two)
    @draft = Onboarding::Draft.new(@user)
  end

  test "keeps valid rooms, clamps counts, drops unknown rooms" do
    @draft.rooms = { "kitchen" => 5, "bedroom" => 2, "bathroom" => "9", "bogus" => 1, "garden" => 0 }
    assert_equal 1, @draft.rooms["kitchen"]   # max 1
    assert_equal 2, @draft.rooms["bedroom"]
    assert_equal 3, @draft.rooms["bathroom"]  # max 3
    assert_not @draft.rooms.key?("bogus")
    assert_not @draft.rooms.key?("garden")
  end

  test "any room, including whole home, can be left out" do
    @draft.rooms = { "kitchen" => 1 }
    assert_equal %w[kitchen], @draft.rooms.keys
    @draft.rooms = {}
    assert_not @draft.selected_rooms?
  end

  test "preload_all! picks every room once and every suggested chore" do
    @draft.preload_all!
    assert_equal Game::Catalog.chore_rooms.keys, @draft.rooms.keys
    total = Game::Catalog.chore_rooms.values.sum { |r| r["chores"].size }
    assert_equal total, @draft.chores.size
  end

  test "chores must belong to a selected room" do
    @draft.rooms = { "kitchen" => 1 }
    @draft.chores = %w[kitchen.oven bedroom.bed nope.nothing kitchen.nope]
    assert_equal [ "kitchen.oven" ], @draft.chores
  end

  test "removing a room drops its chores and frequencies" do
    @draft.rooms = { "kitchen" => 1, "bedroom" => 1 }
    @draft.chores = %w[kitchen.oven bedroom.bed]
    @draft.frequencies = { "bedroom.bed" => "weekly" }
    @draft.rooms = { "kitchen" => 1 }
    assert_equal [ "kitchen.oven" ], @draft.chores
    assert_empty @draft.frequencies
  end

  test "frequencies are validated and default to the catalogue" do
    @draft.rooms = { "kitchen" => 1 }
    @draft.chores = %w[kitchen.oven kitchen.wipe_sides]
    @draft.frequencies = { "kitchen.oven" => "quarterly", "kitchen.wipe_sides" => "made_up", "kitchen.hob" => "daily" }
    assert_equal "quarterly", @draft.frequency_for("kitchen.oven")
    assert_equal "daily", @draft.frequency_for("kitchen.wipe_sides")
    assert_equal({ "kitchen.oven" => "quarterly" }, @draft.frequencies)
  end

  test "default chores come from the selected rooms only" do
    @draft.rooms = { "kitchen" => 1 }
    assert_includes @draft.default_chores, "kitchen.wipe_sides"
    assert_not_includes @draft.default_chores, "bedroom.bed"
  end

  test "the draft persists on the user" do
    @draft.rooms = { "kitchen" => 1 }
    @draft.save!
    assert_equal 1, Onboarding::Draft.new(@user.reload).rooms["kitchen"]
    @draft.clear!
    assert_empty Onboarding::Draft.new(@user.reload).rooms
  end

  test "rooms always come back in catalogue order, even after a database round trip" do
    @draft.rooms = { "garden" => 1, "bedroom" => 1, "kitchen" => 1 }
    @draft.save!
    assert_equal %w[kitchen bedroom garden], Onboarding::Draft.new(@user.reload).rooms.keys
  end
end

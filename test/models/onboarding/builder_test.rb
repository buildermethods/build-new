require "test_helper"

class Onboarding::BuilderTest < ActiveSupport::TestCase
  setup do
    @user = users(:two)
    @user.tasks.destroy_all
    @draft = Onboarding::Draft.new(@user)
  end

  def build_all(rooms:, chores: nil)
    @draft.rooms = rooms
    @draft.chores = chores || @draft.default_chores
    Onboarding::Builder.call(user: @user, draft: @draft)
  end

  test "creates a task per chore with the catalogue's details and frequency" do
    build_all(rooms: { "kitchen" => 1 }, chores: %w[kitchen.wipe_sides kitchen.oven])
    sides = @user.tasks.find_by!(source_key: "kitchen:1:wipe_sides")
    assert_equal "Wipe the kitchen sides", sides.title
    assert_equal "kitchen", sides.room
    assert_equal "Kitchen", sides.room_label
    assert_equal "calendar", sides.recurrence_kind
    assert_equal (0..6).to_a, sides.recurrence_weekdays

    oven = @user.tasks.find_by!(source_key: "kitchen:1:oven")
    assert_equal "completion", oven.recurrence_kind
    assert_equal 30, oven.recurrence_interval_days
  end

  test "a chosen frequency override is applied" do
    @draft.rooms = { "kitchen" => 1 }
    @draft.chores = %w[kitchen.oven]
    @draft.frequencies = { "kitchen.oven" => "quarterly" }
    Onboarding::Builder.call(user: @user, draft: @draft)
    assert_equal 90, @user.tasks.find_by!(source_key: "kitchen:1:oven").recurrence_interval_days
  end

  test "multiple rooms get one set of chores each, labelled" do
    build_all(rooms: { "bedroom" => 2 }, chores: %w[bedroom.floor])
    titles = @user.tasks.order(:source_key).pluck(:title)
    assert_equal [ "Vacuum or mop the bedroom floor (Bedroom 1)", "Vacuum or mop the bedroom floor (Bedroom 2)" ], titles
    assert_equal [ "Bedroom 1", "Bedroom 2" ], @user.tasks.order(:source_key).pluck(:room_label)
  end

  test "running it again never duplicates" do
    build_all(rooms: { "kitchen" => 1 })
    assert_no_difference -> { @user.tasks.count } do
      assert_equal 0, Onboarding::Builder.call(user: @user, draft: @draft)
    end
  end

  test "adding a second bedroom later only creates the new instance" do
    build_all(rooms: { "bedroom" => 1 }, chores: %w[bedroom.floor])
    @draft.rooms = { "bedroom" => 2 }
    @draft.chores = %w[bedroom.floor]
    assert_difference -> { @user.tasks.count }, 1 do
      Onboarding::Builder.call(user: @user, draft: @draft)
    end
  end

  test "every-N-days chores are staggered, not all due on day one" do
    build_all(rooms: { "kitchen" => 1, "bathroom" => 1, "bedroom" => 1, "living_room" => 1, "hallway" => 1, "utility" => 1 }, chores: nil)
    today = @user.today
    due_dates = @user.tasks.where(recurrence_kind: "completion").pluck(:next_due_on)
    assert due_dates.all?(&:present?)
    assert_operator due_dates.uniq.size, :>, 1, "expected first due dates to be spread out"
    assert due_dates.all? { |d| d >= today && d < today + 14 }
  end

  test "a typical household starts with a light first day" do
    build_all(rooms: { "kitchen" => 1, "bathroom" => 1, "bedroom" => 1, "living_room" => 1 }, chores: nil)
    assert_operator @user.tasks.available_on(@user.today).count, :<=, 10
  end

  test "all-chores-everywhere still yields valid tasks" do
    rooms = Game::Catalog.chore_rooms.transform_values { |r| r["max_count"] }
    @draft.rooms = rooms
    @draft.chores = rooms.flat_map { |rk, _| Game::Catalog.chore_rooms[rk]["chores"].map { |c| "#{rk}.#{c['key']}" } }
    Onboarding::Builder.call(user: @user, draft: @draft)
    assert @user.tasks.count > 100
    assert @user.tasks.all?(&:valid?)
  end
end

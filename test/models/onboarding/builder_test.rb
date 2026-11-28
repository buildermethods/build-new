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

  test "every chosen chore is available today, so its timer starts the day it is chosen" do
    build_all(rooms: { "kitchen" => 1, "bathroom" => 1, "bedroom" => 1, "living_room" => 1 }, chores: nil)
    today = @user.today
    assert @user.tasks.any?
    assert @user.tasks.all? { |t| t.next_due_on == today }
    assert_equal @user.tasks.count, @user.tasks.available_on(today).count
  end

  test "all-chores-everywhere still yields valid tasks" do
    rooms = Game::Catalog.chore_rooms.transform_values { |r| r["max_count"] }
    @draft.rooms = rooms
    @draft.chores = rooms.flat_map { |rk, _| Game::Catalog.chore_rooms[rk]["chores"].map { |c| "#{rk}.#{c['key']}" } }
    Onboarding::Builder.call(user: @user, draft: @draft)
    assert @user.tasks.count > 100
    assert @user.tasks.all?(&:valid?)
  end

  test "an archived chore can be added again later" do
    build_all(rooms: { "kitchen" => 1 }, chores: %w[kitchen.oven])
    oven = @user.tasks.find_by!(source_key: "kitchen:1:oven")
    oven.complete!(today: @user.today)
    oven.archive!
    assert_nil oven.reload.source_key
    assert_difference -> { @user.tasks.pending.count }, 1 do
      Onboarding::Builder.call(user: @user, draft: @draft)
    end
  end

  test "the dining room is offered with sensible chores and its own icon room" do
    room = Game::Catalog.chore_rooms["dining_room"]
    assert_equal "Dining room", room["label"]
    assert_includes Task::ROOMS, "dining_room"
    assert_equal "daily", Game::Catalog.chore("dining_room", "table")["frequency"]
    assert_equal "weekly", Game::Catalog.chore("dining_room", "floor")["frequency"]
    assert_equal "monthly", Game::Catalog.chore("dining_room", "polish")["frequency"]
  end

  test "choosing the dining room builds tasks in that room with the goblins as the monster" do
    build_all(rooms: { "dining_room" => 1 })
    task = @user.tasks.find_by!(source_key: "dining_room:1:table")
    assert_equal "dining_room", task.room
    assert_equal "Dining room", task.room_label
    assert_equal "counter_goblins", task.monster_key_or_default
  end
end

require "test_helper"

class Onboarding::ChoreCatalogTest < ActiveSupport::TestCase
  ALLOWED_KEYS = %w[key title minutes effort frequency default category].freeze

  test "every room maps to a real task room and has chores" do
    Game::Catalog.chore_rooms.each do |key, room|
      assert_includes Task::ROOMS, room["room"], "#{key} has an unknown task room"
      assert room["chores"].any?, "#{key} has no chores"
      assert_operator room["max_count"], :>=, 1
    end
  end

  test "every chore is complete and builds a valid task" do
    user = users(:one)
    Game::Catalog.chore_rooms.each do |room_key, room|
      room["chores"].each do |chore|
        assert_empty chore.keys - ALLOWED_KEYS, "#{room_key}.#{chore['key']} has unexpected keys (an unquoted comma in YAML?)"
        assert chore["title"].present?
        assert Game::Catalog.frequency(chore["frequency"]), "#{room_key}.#{chore['key']} has unknown frequency"

        task = user.tasks.build(title: chore["title"], room: room["room"], category: chore["category"] || room["category"],
                                duration_minutes: chore["minutes"], effort: chore["effort"], recurrence_kind: "none")
        assert task.valid?, "#{room_key}.#{chore['key']}: #{task.errors.full_messages.to_sentence}"
      end
    end
  end

  test "chore keys are unique within a room" do
    Game::Catalog.chore_rooms.each do |room_key, room|
      keys = room["chores"].map { |c| c["key"] }
      assert_equal keys.uniq, keys, "#{room_key} repeats a chore key"
    end
  end

  test "every frequency is a valid recurrence" do
    Game::Catalog.frequencies.each do |key, f|
      task = users(:one).tasks.build(title: "x", recurrence_kind: f["kind"], recurrence_weekdays: f["weekdays"] || [], recurrence_interval_days: f["interval"])
      assert task.valid?, "#{key}: #{task.errors.full_messages.to_sentence}"
    end
  end

  test "the headline examples are present with sensible defaults" do
    assert_equal "daily", Game::Catalog.chore("kitchen", "wipe_sides")["frequency"]
    assert_equal "monthly", Game::Catalog.chore("kitchen", "oven")["frequency"]
    assert_equal "weekly", Game::Catalog.chore("bathroom", "floor")["frequency"]
  end

  test "each room suggests some pre-ticked essentials but not everything" do
    Game::Catalog.chore_rooms.each do |key, room|
      defaults = room["chores"].count { |c| c["default"] }
      assert_operator defaults, :>=, 1, "#{key} suggests nothing"
      assert_operator defaults, :<=, room["chores"].size
    end
  end
end

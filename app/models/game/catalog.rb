# frozen_string_literal: true

module Game
  # Read-only game data loaded from config/game/*.yml.
  class Catalog
    FALLBACK_MONSTER = "dust_bunny_horde"

    class << self
      def monsters
        @monsters ||= load_yaml("monsters.yml")
      end

      def monster(key)
        monsters[key.to_s] || monsters.fetch(FALLBACK_MONSTER)
      end

      def monster_key_for(room:, category:)
        found = monsters.find { |_key, m| Array(m["rooms"]).include?(room) || Array(m["categories"]).include?(category) }
        found ? found.first : FALLBACK_MONSTER
      end

      def energy_modes
        @energy_modes ||= load_yaml("energy_modes.yml")
      end

      def energy_mode(key)
        energy_modes[key.to_s] || energy_modes.fetch("ready")
      end

      # Setup chore catalogue: rooms (with their chores) and the frequency
      # vocabulary that maps onto Tasks::Recurrence.
      def chore_rooms
        chore_catalog.fetch("rooms")
      end

      def frequencies
        chore_catalog.fetch("frequencies")
      end

      def frequency(key)
        frequencies[key.to_s]
      end

      def chore(room_key, chore_key)
        chore_rooms.dig(room_key.to_s, "chores")&.find { |c| c["key"] == chore_key.to_s }
      end

      def achievements
        @achievements ||= load_yaml("achievements.yml")
      end

      def decoration_slots
        decoration_config.fetch("slots")
      end

      # key => { "name", "slot", "price" }
      def decorations
        decoration_config.fetch("items")
      end

      def decoration(key)
        decorations[key.to_s]
      end

      def reset!
        @decoration_config = nil
        @chore_catalog = nil
        @achievements = nil
        @monsters = nil
        @energy_modes = nil
      end

      private
        def chore_catalog
          @chore_catalog ||= load_yaml("chore_catalog.yml")
        end

        def decoration_config
          @decoration_config ||= load_yaml("decorations.yml")
        end

        def load_yaml(name)
          YAML.load_file(Rails.root.join("config/game", name))
        end
    end
  end
end

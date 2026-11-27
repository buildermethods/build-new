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

      def reset!
        @monsters = nil
      end

      private
        def load_yaml(name)
          YAML.load_file(Rails.root.join("config/game", name))
        end
    end
  end
end

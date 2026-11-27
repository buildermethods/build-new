# frozen_string_literal: true

module Game
  # XP and coin values. Pure functions over config/game/economy.yml so the
  # numbers can be rebalanced without touching code.
  class Economy
    class << self
      def xp_for(effort)
        config.fetch("xp_by_effort").fetch(effort.to_s)
      end

      def coins_for(effort)
        (xp_for(effort) * config.fetch("coins_per_xp")).round
      end

      def routine_bonus
        { xp: config.fetch("routine_bonus_xp"), coins: config.fetch("routine_bonus_coins") }
      end

      # Cumulative XP needed to reach `level` (level 1 needs none).
      def xp_to_reach(level)
        config.fetch("level_base") * level * (level - 1) / 2
      end

      def level_for(xp)
        level = 1
        level += 1 while xp >= xp_to_reach(level + 1)
        level
      end

      private
        def config
          @config ||= YAML.load_file(Rails.root.join("config/game/economy.yml"))
        end
    end
  end
end

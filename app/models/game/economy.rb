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

      private
        def config
          @config ||= YAML.load_file(Rails.root.join("config/game/economy.yml"))
        end
    end
  end
end

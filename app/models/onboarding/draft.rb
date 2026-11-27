# frozen_string_literal: true

module Onboarding
  # The user's in-progress setup choices, stored on users.onboarding_draft so
  # refresh and Back keep them. Every setter validates against the chore
  # catalogue, so nothing from a request is trusted.
  #
  #   rooms:        { "kitchen" => 1, "bedroom" => 2 }
  #   chores:       [ "kitchen.wipe_sides", ... ]        (room.chore keys)
  #   frequencies:  { "kitchen.oven" => "monthly" }      (overrides)
  class Draft
    attr_reader :user

    def initialize(user)
      @user = user
      @data = (user.onboarding_draft || {}).deep_stringify_keys
    end

    # Room => instance count, always in catalogue order (jsonb does not keep
    # key order).
    def rooms
      stored = @data["rooms"] || {}
      Game::Catalog.chore_rooms.keys.each_with_object({}) { |key, out| out[key] = stored[key] if stored.key?(key) }
    end

    def chores
      @data["chores"] || []
    end

    def frequencies
      @data["frequencies"] || {}
    end

    def rooms=(raw)
      clean = {}
      Hash(raw).each do |key, count|
        room = Game::Catalog.chore_rooms[key.to_s]
        next unless room && !room["always"]

        n = count.to_i.clamp(0, room.fetch("max_count"))
        clean[key.to_s] = n if n.positive?
      end
      Game::Catalog.chore_rooms.each { |key, room| clean[key] = 1 if room["always"] }
      @data["rooms"] = clean
      prune!
    end

    def chores=(keys)
      @data["chores"] = Array(keys).map(&:to_s).uniq.select { |k| valid_chore?(k) }
      prune!
    end

    def frequencies=(raw)
      @data["frequencies"] = Hash(raw).each_with_object({}) do |(chore_key, freq), out|
        out[chore_key.to_s] = freq.to_s if chores.include?(chore_key.to_s) && Game::Catalog.frequency(freq)
      end
    end

    # Pre-ticked suggestions for the selected rooms.
    def default_chores
      rooms.keys.flat_map do |room_key|
        Game::Catalog.chore_rooms.fetch(room_key)["chores"].select { |c| c["default"] }.map { |c| "#{room_key}.#{c['key']}" }
      end
    end

    def frequency_for(chore_key)
      frequencies[chore_key] || Game::Catalog.chore(*chore_key.split("."))&.fetch("frequency")
    end

    def selected_rooms?
      rooms.keys.any? { |k| !Game::Catalog.chore_rooms.dig(k, "always") }
    end

    def save!
      user.update!(onboarding_draft: @data)
    end

    def clear!
      user.update!(onboarding_draft: {})
    end

    private
      def valid_chore?(key)
        room_key, chore_key = key.split(".", 2)
        rooms.key?(room_key) && Game::Catalog.chore(room_key, chore_key).present?
      end

      def prune!
        @data["chores"] = chores.select { |k| valid_chore?(k) }
        @data["frequencies"] = frequencies.select { |k, _| chores.include?(k) }
      end
  end
end

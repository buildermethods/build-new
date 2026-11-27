# frozen_string_literal: true

module Sanctuary
  # Places an owned decoration in its slot (replacing whatever was there), or
  # empties a slot. Only owned items can be equipped.
  class Equip
    def self.call(user:, key:)
      item = Game::Catalog.decoration(key)
      return false unless item && user.owned_decorations.exists?(decoration_key: key.to_s)

      placement = user.sanctuary_placements.find_or_initialize_by(slot: item["slot"])
      placement.update!(decoration_key: key.to_s)
      true
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def self.clear(user:, slot:)
      user.sanctuary_placements.where(slot: slot.to_s).destroy_all
      true
    end
  end
end

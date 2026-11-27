# frozen_string_literal: true

module Sanctuary
  # Places an owned decoration in a room's slot (replacing whatever was there),
  # or empties a slot. Rules: the item must be owned, the room must be unlocked
  # (by the highest level ever reached, so rooms are never lost), the item must
  # suit the room, and an item sits in one place at a time (placing it moves it).
  class Equip
    DEFAULT_ROOM = "living_room"

    def self.unlocked?(user, room)
      config = Game::Catalog.cottage_rooms[room.to_s]
      config.present? && user.progress.peak_level >= config["unlock_level"]
    end

    def self.call(user:, key:, room: DEFAULT_ROOM)
      room = room.presence || DEFAULT_ROOM
      item = Game::Catalog.decoration(key)
      return false unless item && unlocked?(user, room)
      return false unless user.owned_decorations.exists?(decoration_key: key.to_s)
      return false if item["rooms"] && !item["rooms"].include?(room.to_s)

      SanctuaryPlacement.transaction do
        user.sanctuary_placements.where(decoration_key: key.to_s).destroy_all
        placement = user.sanctuary_placements.find_or_initialize_by(room: room.to_s, slot: item["slot"])
        placement.update!(decoration_key: key.to_s)
      end
      true
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def self.clear(user:, slot:, room: DEFAULT_ROOM)
      user.sanctuary_placements.where(room: room.presence || DEFAULT_ROOM, slot: slot.to_s).destroy_all
      true
    end
  end
end

# frozen_string_literal: true

class SanctuaryPlacement < ApplicationRecord
  belongs_to :user

  validates :room, inclusion: { in: ->(_) { Game::Catalog.cottage_rooms.keys } }
  validates :slot, inclusion: { in: ->(_) { Game::Catalog.decoration_slots } }
  validates :decoration_key, inclusion: { in: ->(_) { Game::Catalog.decorations.keys } }
  validate :decoration_fits_slot

  private
    def decoration_fits_slot
      item = Game::Catalog.decoration(decoration_key)
      return unless item

      errors.add(:slot, "does not match the decoration") if item["slot"] != slot
      allowed = item["rooms"]
      errors.add(:room, "does not suit this decoration") if allowed && !allowed.include?(room)
    end
end

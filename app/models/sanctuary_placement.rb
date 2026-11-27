# frozen_string_literal: true

class SanctuaryPlacement < ApplicationRecord
  belongs_to :user

  validates :slot, inclusion: { in: ->(_) { Game::Catalog.decoration_slots } }
  validates :decoration_key, inclusion: { in: ->(_) { Game::Catalog.decorations.keys } }
  validate :decoration_fits_slot

  private
    def decoration_fits_slot
      item = Game::Catalog.decoration(decoration_key)
      errors.add(:slot, "does not match the decoration") if item && item["slot"] != slot
    end
end

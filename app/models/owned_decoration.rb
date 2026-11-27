# frozen_string_literal: true

class OwnedDecoration < ApplicationRecord
  belongs_to :user

  validates :decoration_key, presence: true, inclusion: { in: ->(_) { Game::Catalog.decorations.keys } }
end

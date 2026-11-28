# frozen_string_literal: true

class UserAchievement < ApplicationRecord
  belongs_to :user

  validates :key, inclusion: { in: ->(_) { Game::Catalog.achievements.keys } }
end

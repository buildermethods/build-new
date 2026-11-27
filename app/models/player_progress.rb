# frozen_string_literal: true

class PlayerProgress < ApplicationRecord
  belongs_to :user

  before_save { self.peak_level = [ peak_level, level ].max }

  validates :xp, :coins, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def level
    Game::Economy.level_for(xp)
  end

  def xp_into_level
    xp - Game::Economy.xp_to_reach(level)
  end

  def xp_for_next_level
    Game::Economy.xp_to_reach(level + 1) - Game::Economy.xp_to_reach(level)
  end

  def as_player_json
    { level: level, xp: xp, coins: coins, xp_into_level: xp_into_level, xp_for_next_level: xp_for_next_level }
  end
end

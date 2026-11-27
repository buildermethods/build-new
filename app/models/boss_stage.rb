# frozen_string_literal: true

class BossStage < ApplicationRecord
  belongs_to :boss_battle

  validates :title, presence: true, length: { maximum: 160 }

  def done?
    completed_at.present?
  end
end

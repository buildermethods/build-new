# frozen_string_literal: true

class BossStage < ApplicationRecord
  belongs_to :boss_battle
  belongs_to :task, optional: true

  validates :title, presence: true, length: { maximum: 160 }

  # A stage tied to a real chore clears itself when that chore is completed.
  def linked?
    task_id.present?
  end

  def done?
    completed_at.present?
  end
end

# frozen_string_literal: true

class DailyIntention < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :on_date, presence: true
  validate :task_belongs_to_user
  validates :anchor, inclusion: { in: Onboarding::Complete::ANCHORS }, allow_blank: true

  private
    def task_belongs_to_user
      errors.add(:task, "must be yours") if task && task.user_id != user_id
    end
end

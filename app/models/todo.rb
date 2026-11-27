# frozen_string_literal: true

# A quick one-off to-do ("call the plumber"). Deliberately lightweight: no
# monster, no recurrence, and only a tiny capped reward.
class Todo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 200 }

  before_validation { self.title = title.to_s.squish }

  scope :open, -> { where(completed_at: nil) }
  scope :done, -> { where.not(completed_at: nil) }
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def done?
    completed_at.present?
  end

  # Ticks the to-do. Returns the reward result when XP was awarded, else nil.
  # Re-ticking after an untick never pays again (the ledger row is keyed by id).
  def complete!(at: Time.current)
    return nil if done?

    update!(completed_at: at)
    Game::AwardTodo.call(user: user, todo: self)
  end

  def uncomplete!
    update!(completed_at: nil)
  end
end

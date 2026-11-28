# frozen_string_literal: true

# A quick one-off to-do ("call the plumber"). Deliberately lightweight: no
# monster, no recurrence, and only a tiny capped reward.
class Todo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 200 }

  before_validation { self.title = title.to_s.squish }

  scope :open, -> { where(completed_at: nil) }
  scope :done, -> { where.not(completed_at: nil) }
  # Reminders first (soonest date first), then the rest newest first. A date in
  # the past is simply a reminder that is ready, never "overdue".
  scope :reminders_first, -> { order(Arel.sql("remind_on IS NULL, remind_on ASC, created_at DESC, id DESC")) }
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  # "Reminder: today" / "Reminder: Thu 4 Dec". Past dates read the same way, as
  # a plain date, so nothing ever says "overdue".
  def reminder_text(today)
    return unless remind_on

    remind_on == today ? "Reminder: today" : "Reminder: #{remind_on.strftime('%a %-d %b')}"
  end

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

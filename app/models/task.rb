# frozen_string_literal: true

class Task < ApplicationRecord
  ROOMS = %w[kitchen bathroom bedroom living_room laundry kids_room garden office other].freeze
  CATEGORIES = %w[cleaning laundry school admin kids wellbeing outdoors other].freeze
  EFFORTS = %w[tiny small medium large boss].freeze
  PRIORITIES = %w[low normal high].freeze
  RECURRENCE_KINDS = %w[none calendar completion].freeze
  STATUSES = %w[active paused archived].freeze

  belongs_to :user
  has_many :completions, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :notes, length: { maximum: 2000 }
  validates :room, inclusion: { in: ROOMS }
  validates :category, inclusion: { in: CATEGORIES }
  validates :effort, inclusion: { in: EFFORTS }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :status, inclusion: { in: STATUSES }
  validates :recurrence_kind, inclusion: { in: RECURRENCE_KINDS }
  validates :duration_minutes, numericality: { only_integer: true, in: 1..240 }
  validates :recurrence_interval_days, numericality: { only_integer: true, in: 1..365 },
                                       if: -> { recurrence_kind == "completion" }
  validate :weekdays_valid, if: -> { recurrence_kind == "calendar" }

  before_validation :normalize_recurrence
  before_save :schedule_first_due_date

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
  scope :pending, -> { where(status: "active", completed_at: nil) }

  # Open tasks that can be worked on today: not deferred past today and not
  # waiting for a future due date.
  def self.available_on(date)
    pending.where("deferred_until IS NULL OR deferred_until <= ?", date)
        .where("next_due_on IS NULL OR next_due_on <= ?", date)
  end

  def recurring?
    recurrence_kind != "none"
  end

  def available_on?(date)
    status == "active" && completed_at.nil? &&
      (deferred_until.nil? || deferred_until <= date) &&
      (next_due_on.nil? || next_due_on <= date)
  end

  # Marks the task done on `today`. Returns the new Completion, or nil when the
  # task was not available (already done, paused, deferred), which makes
  # double-clicks and retries harmless.
  def complete!(today:, at: Time.current)
    with_lock do
      next nil unless available_on?(today)

      completion = completions.create!(user: user, completed_at: at, previous_next_due_on: next_due_on)
      if recurring?
        update!(next_due_on: Tasks::Recurrence.next_due_on(self, today), deferred_until: nil)
      else
        update!(completed_at: at, deferred_until: nil)
      end
      completion
    end
  end

  # Reverses the latest un-undone completion. Returns it, or nil if none.
  def uncomplete!(at: Time.current)
    with_lock do
      completion = completions.active.newest_first.first
      next nil unless completion

      completion.update!(undone_at: at)
      if recurring?
        update!(next_due_on: completion.previous_next_due_on)
      else
        update!(completed_at: nil)
      end
      completion
    end
  end

  # Skipping is penalty-free. Recurring tasks move to their next occurrence;
  # one-off tasks come back tomorrow.
  def skip!(today:)
    with_lock do
      if recurring?
        update!(next_due_on: Tasks::Recurrence.next_due_on(self, today), deferred_until: nil)
      else
        update!(deferred_until: today + 1)
      end
    end
  end

  def defer!(until_date:)
    update!(deferred_until: until_date)
  end

  def archive!
    update!(status: "archived")
  end

  def monster_key_or_default
    monster_key.presence || Game::Catalog.monster_key_for(room: room, category: category)
  end

  def fantasy_title_or_default
    fantasy_title.presence || Game::Catalog.monster(monster_key_or_default)["quest_title"]
  end

  def xp
    Game::Economy.xp_for(effort)
  end

  def coins
    Game::Economy.coins_for(effort)
  end

  private
    def normalize_recurrence
      self.recurrence_weekdays = Array(recurrence_weekdays).reject(&:blank?).map(&:to_i).uniq.sort
      case recurrence_kind
      when "none"
        self.recurrence_weekdays = []
        self.recurrence_interval_days = nil
      when "calendar"
        self.recurrence_interval_days = nil
      when "completion"
        self.recurrence_weekdays = []
      end
    end

    def weekdays_valid
      if recurrence_weekdays.empty? || recurrence_weekdays.any? { |d| !(0..6).cover?(d) }
        errors.add(:recurrence_weekdays, "must include at least one day")
      end
    end

    def schedule_first_due_date
      return unless new_record? || will_save_change_to_recurrence_kind? || will_save_change_to_recurrence_weekdays?

      self.next_due_on = Tasks::Recurrence.initial_due_on(self, user.today)
    end
end

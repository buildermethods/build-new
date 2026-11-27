# frozen_string_literal: true

module Tasks
  # Schedule maths for recurring tasks. Pure Ruby over dates so it is easy to
  # test. A task is a template with a single next_due_on; missed days never
  # create extra copies.
  #
  #   calendar   - fixed weekdays (0 = Sunday .. 6 = Saturday), "every Thursday"
  #   completion - N days after the latest completion, "every 7 days"
  module Recurrence
    module_function

    # First due date for a task that has just been created or re-scheduled.
    def initial_due_on(task, today)
      case task.recurrence_kind
      when "calendar" then next_weekday(task.recurrence_weekdays, from: today, inclusive: true)
      end
    end

    # Due date after completing (or skipping) on `done_on`.
    def next_due_on(task, done_on)
      case task.recurrence_kind
      when "calendar"
        # Anchor on the later of today and the current due date so finishing a
        # Thursday task on Wednesday does not just land on the same Thursday.
        anchor = [ done_on, task.next_due_on ].compact.max
        next_weekday(task.recurrence_weekdays, from: anchor, inclusive: false)
      when "completion"
        done_on + task.recurrence_interval_days
      end
    end

    def next_weekday(weekdays, from:, inclusive:)
      days = weekdays.map(&:to_i)
      start = inclusive ? from : from + 1
      (0..6).map { |offset| start + offset }.find { |date| days.include?(date.wday) }
    end
  end
end

# frozen_string_literal: true

module Habits
  # Flexible consistency: how many days this week (Monday to Sunday) the player
  # did something, against a target of four. There is no streak that resets and
  # nothing is lost by a quiet day; the week simply starts fresh on Monday.
  class WeekProgress
    TARGET = 4
    DAILY_GOAL = 3
    LABELS = %w[Mon Tue Wed Thu Fri Sat Sun].freeze

    attr_reader :today

    def initialize(user, today: user.today)
      @user = user
      @today = today
    end

    def week_start
      today.beginning_of_week(:monday)
    end

    def active_dates
      @active_dates ||= begin
        from = @user.zone.local(week_start.year, week_start.month, week_start.day).beginning_of_day
        to = from + 7.days
        @user.completions.active.where(completed_at: from...to).pluck(:completed_at)
             .map { |t| t.in_time_zone(@user.zone).to_date }
      end
    end

    def active_days
      active_dates.uniq.size
    end

    def wins_today
      active_dates.count(today)
    end

    def days
      (0..6).map do |i|
        date = week_start + i
        { label: LABELS[i], date: date.iso8601, active: active_dates.include?(date), today: date == today }
      end
    end

    def as_json(*)
      { days: days, active_days: active_days, target: TARGET, met: active_days >= TARGET }
    end

    def today_json
      { wins: wins_today, goal: DAILY_GOAL }
    end
  end
end

# frozen_string_literal: true

module Habits
  # A kind look back at the last few weeks (Monday to Sunday, in the player's own
  # timezone). Always encouraging: a quieter week is described as rest, never as
  # failure, and nothing is ranked against other people.
  class Insights
    WEEKS = 4
    DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

    def self.call(user, today: user.today)
      new(user, today).call
    end

    def initialize(user, today)
      @user = user
      @today = today
    end

    def call
      weeks = (0...WEEKS).map { |ago| week_stats(ago) }.reverse # oldest first
      current = weeks.last
      previous = weeks[-2]
      { this_week: current, last_week: previous, weeks: weeks.map { |w| w.slice(:label, :quests, :active_days) },
        message: message(current, previous) }
    end

    private
      def week_start(ago)
        @today.beginning_of_week(:monday) - (7 * ago)
      end

      def range(ago)
        from = week_start(ago)
        start = @user.zone.local(from.year, from.month, from.day).beginning_of_day
        start...(start + 7.days)
      end

      def week_stats(ago)
        range = range(ago)
        rows = @user.completions.active.where(completed_at: range).joins(:task)
                    .pluck("completions.completed_at", "tasks.room", "tasks.duration_minutes")
        dates = rows.map { |at, _, _| at.in_time_zone(@user.zone).to_date }
        {
          label: ago.zero? ? "This week" : (ago == 1 ? "Last week" : "#{week_start(ago).strftime('%-d %b')}"),
          starts_on: week_start(ago).iso8601,
          quests: rows.size,
          active_days: dates.uniq.size,
          quick_wins: rows.count { |_, _, minutes| minutes <= 5 },
          xp: @user.reward_transactions.where(created_at: range).sum(:xp_delta),
          coins: @user.reward_transactions.where(created_at: range).where("coin_delta > 0").sum(:coin_delta),
          todos_done: @user.todos.where(completed_at: range).count,
          boss_stages: @user.reward_transactions.where(kind: "boss_stage", created_at: range).count,
          top_room: top_room(rows),
          busiest_day: busiest_day(dates)
        }
      end

      def top_room(rows)
        counts = rows.map { |_, room, _| room }.reject { |r| r == "other" }.tally
        room, = counts.max_by { |_, n| n }
        room&.tr("_", " ")
      end

      def busiest_day(dates)
        day, = dates.map(&:wday).tally.max_by { |_, n| n }
        day && DAY_NAMES[day]
      end

      def message(current, previous)
        quests = current[:quests]
        last = previous[:quests]
        if quests.zero? && last.zero?
          "This week is a blank page. One small win is a lovely way to begin."
        elsif quests.zero?
          "A quiet week so far, and that's completely fine. Rest is part of the rhythm."
        elsif last.zero?
          "A fresh start: #{quests} #{quests == 1 ? 'quest' : 'quests'} finished. Lovely."
        elsif quests >= last
          "You're keeping a steady rhythm: #{quests} finished, up from #{last} last week."
        else
          "A lighter week than last week, and that's fine. #{quests} #{quests == 1 ? 'win' : 'wins'} is still progress."
        end
      end
  end
end

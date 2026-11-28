# frozen_string_literal: true

module Challenges
  # The player's current daily and weekly challenge with progress and claim
  # state. Selection is deterministic from the date, so everyone sees the same
  # challenge on the same day and nothing is random. Progress comes from existing
  # records; a claim is just the ledger row (kind "challenge").
  class Current
    PERIODS = %w[daily weekly].freeze

    def self.call(user)
      new(user).call
    end

    def self.key_for(period, challenge_key, today)
      stamp = period == "daily" ? today.iso8601 : today.strftime("%G-W%V")
      "#{period}:#{stamp}:#{challenge_key}"
    end

    def initialize(user, today: user.today)
      @user = user
      @today = today
    end

    def call
      PERIODS.map { |period| build(period) }
    end

    def find(period)
      PERIODS.include?(period.to_s) ? build(period.to_s) : nil
    end

    private
      def build(period)
        list = Game::Catalog.challenges.fetch(period)
        config = list[period == "daily" ? @today.yday % list.size : @today.cweek % list.size]
        current = [ metric(config["metric"], range(period)), config["target"] ].min
        key = self.class.key_for(period, config["key"], @today)
        {
          period: period, key: key, name: config["name"], description: config["description"],
          current: current, target: config["target"], xp: config["xp"], coins: config["coins"],
          complete: current >= config["target"],
          claimed: RewardTransaction.exists?(user: @user, kind: "challenge", reference: key)
        }
      end

      def range(period)
        from = period == "daily" ? @today : @today.beginning_of_week(:monday)
        start = @user.zone.local(from.year, from.month, from.day).beginning_of_day
        start...(start + (period == "daily" ? 1 : 7).days)
      end

      def metric(name, range)
        completions = @user.completions.active.where(completed_at: range)
        case name
        when "completions" then completions.count
        when "quick" then completions.joins(:task).where("tasks.duration_minutes <= 5").count
        when /\Aroom:(.+)\z/ then completions.joins(:task).where(tasks: { room: Regexp.last_match(1) }).count
        when /\Acategory:(.+)\z/ then completions.joins(:task).where(tasks: { category: Regexp.last_match(1) }).count
        when "active_days" then completions.pluck(:completed_at).map { |t| t.in_time_zone(@user.zone).to_date }.uniq.size
        when "starts" then @user.reward_transactions.where(kind: "start", created_at: range).count
        when "boss_stages" then @user.reward_transactions.where(kind: "boss_stage", created_at: range).count
        else 0
        end
      end
  end
end

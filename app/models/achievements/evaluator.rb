# frozen_string_literal: true

module Achievements
  # Awards any badges whose threshold has been reached. Deterministic and
  # idempotent (unique per user and key); badges are never taken away.
  class Evaluator
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    # Returns the newly earned badges as [{ key:, name:, description: }].
    def call
      earned = @user.user_achievements.pluck(:key)
      Game::Catalog.achievements.filter_map do |key, config|
        next if earned.include?(key)
        next unless metric(config["metric"]) >= config["threshold"]

        begin
          @user.user_achievements.create!(key: key, earned_at: Time.current)
        rescue ActiveRecord::RecordNotUnique
          next
        end
        { key: key, name: config["name"], description: config["description"] }
      end
    end

    private
      def completions
        @completions ||= @user.completions.active
      end

      def metric(name)
        case name
        when "completions" then completions.count
        when "quick" then completions.joins(:task).where("tasks.duration_minutes <= 5").count
        when /\Acategory:(.+)\z/ then completions.joins(:task).where(tasks: { category: Regexp.last_match(1) }).count
        when /\Aroom:(.+)\z/ then completions.joins(:task).where(tasks: { room: Regexp.last_match(1) }).count
        when "week_days" then Habits::WeekProgress.new(@user).active_days
        when "comeback" then comeback? ? 1 : 0
        when "decorations" then @user.owned_decorations.count
        else 0
        end
      end

      # True if any completion came 7+ days after the one before it.
      def comeback?
        dates = completions.pluck(:completed_at).map { |t| t.in_time_zone(@user.zone).to_date }.uniq.sort
        dates.each_cons(2).any? { |a, b| (b - a).to_i >= 7 }
      end
  end
end

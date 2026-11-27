# frozen_string_literal: true

module Quests
  # Builds the dashboard's props from check-in params. Read-only: nothing here
  # changes tasks, rewards or schedules.
  class Dashboard
    TIME_OPTIONS = [ 5, 10, 15, 20, 30, 45, 60 ].freeze
    DEFAULT_MINUTES = 30
    DEFAULT_ENERGY = "ready"
    EASIER = { "hero" => "ready", "ready" => "gentle", "gentle" => "survival", "survival" => "survival" }.freeze

    def initialize(user:, params:)
      @user = user
      @params = params
      @today = user.today
      @minutes = params[:minutes].to_i.clamp(5, 180) if params[:minutes].present?
      @energy = Game::Catalog.energy_modes.key?(params[:energy].to_s) ? params[:energy].to_s : nil
      @context = params[:context].to_s
    end

    def props
      {
        greeting: greeting,
        available_count: @user.tasks.available_on(@today).count,
        energy_modes: Game::Catalog.energy_modes.map { |key, m| { key: key, label: m["label"], description: m["description"] } },
        time_options: TIME_OPTIONS,
        checkin: { minutes: @minutes || DEFAULT_MINUTES, energy: @energy || DEFAULT_ENERGY, context: @context.first(Planner::MAX_CONTEXT) },
        suggestions: suggestions,
        plan: (plan_requested? ? plan.as_json : nil),
        single: (@params[:just].present? ? single : nil),
        sanctuary: SanctuaryPresenter.new(@user).as_json
      }
    end

    private
      def minutes
        @minutes || DEFAULT_MINUTES
      end

      def energy
        @energy || DEFAULT_ENERGY
      end

      def plan_requested?
        @params[:plan].present?
      end

      def plan
        Planner.call(user: @user, minutes: minutes, energy: energy, today: @today, context: @context)
      end

      def suggestions
        Recommender.new(user: @user, minutes: minutes, energy: energy, today: @today).call.tasks.first(3).map do |task|
          TaskPresenter.new(task, today: @today).as_json
        end
      end

      # One actionable task for "Just tell me what to do". `easier` steps down
      # an energy level; `exclude` carries swapped-out ids.
      def single
        level = @params[:easier].present? ? EASIER.fetch(energy) : energy
        exclude = Array(@params[:exclude]).map(&:to_i)
        recommender = Recommender.new(user: @user, minutes: minutes, energy: level, today: @today, exclude: exclude)
        task = recommender.call.tasks.first || recommender.eligible.first
        return { quest: nil, energy: level } unless task

        { quest: TaskPresenter.new(task, today: @today).as_json, energy: level }
      end

      def greeting
        hour = Time.current.in_time_zone(ActiveSupport::TimeZone[@user.timezone.to_s] || "UTC").hour
        part = hour < 12 ? "morning" : (hour < 18 ? "afternoon" : "evening")
        "Good #{part}, adventurer!"
      end
  end
end

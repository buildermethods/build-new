# frozen_string_literal: true

module Quests
  # Props for the step-by-step "Plan my day" screens (time, energy, result).
  # Read-only: nothing here changes tasks, rewards or schedules.
  class PlanPage
    TIME_OPTIONS = [ 5, 10, 15, 20, 30, 45, 60 ].freeze
    DEFAULT_MINUTES = 30
    DEFAULT_ENERGY = "ready"

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
        energy_modes: Game::Catalog.energy_modes.map { |key, m| { key: key, label: m["label"], description: m["description"] } },
        time_options: TIME_OPTIONS,
        checkin: { minutes: @minutes || DEFAULT_MINUTES, energy: @energy || DEFAULT_ENERGY, context: @context.first(Planner::MAX_CONTEXT) },
        plan: (@params[:plan].present? ? plan.as_json : nil),
        treat: @user.treat
      }
    end

    private
      def plan
        Planner.call(user: @user, minutes: @minutes || DEFAULT_MINUTES, energy: @energy || DEFAULT_ENERGY,
                     today: @today, context: @context)
      end
  end
end

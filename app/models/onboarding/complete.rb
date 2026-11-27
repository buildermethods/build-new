# frozen_string_literal: true

module Onboarding
  # Finishes first-run setup: creates the chosen starter tasks, gifts a first
  # decoration so the cottage isn't bare, and marks the user onboarded. Task
  # keys are validated against the catalog; nothing else from the request is
  # trusted.
  class Complete
    MAX_TASKS = 20
    GIFT = "fern_pot"

    def self.call(user:, task_keys:, display_name: nil)
      new(user, task_keys, display_name).call
    end

    def initialize(user, task_keys, display_name)
      @user = user
      @task_keys = Array(task_keys).map(&:to_s).uniq.first(MAX_TASKS)
      @display_name = display_name.to_s.squish.first(40)
    end

    def call
      return false if @user.onboarded?

      User.transaction do
        Game::Catalog.starter_tasks.select { |t| @task_keys.include?(t["key"]) }.each { |attrs| create_task(attrs) }
        @user.owned_decorations.find_or_create_by!(decoration_key: GIFT)
        Sanctuary::Equip.call(user: @user, key: GIFT)
        @user.update!(display_name: @display_name.presence, onboarded_at: Time.current)
      end
      true
    end

    private
      def create_task(attrs)
        @user.tasks.create!(attrs.slice("title", "room", "category", "duration_minutes", "effort",
                                        "recurrence_kind", "recurrence_interval_days", "recurrence_weekdays"))
      end
  end
end

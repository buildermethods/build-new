# frozen_string_literal: true

module Quests
  # A one-shot, self-cleaning check that the real Claude integration works:
  # builds a throwaway household, asks the AI planner for a plan, validates it
  # with the same rules as production, then rolls everything back so no data is
  # left behind. Used by `bin/rails nest_quest:check_planner`.
  class PlannerCheck
    Result = Struct.new(:ok, :plan, :error, :tasks, keyword_init: true)

    def self.call(client:)
      result = nil
      ActiveRecord::Base.transaction do
        result = run(client)
        raise ActiveRecord::Rollback
      end
      result
    end

    def self.run(client)
      user = User.create!(email: "planner-check-#{SecureRandom.hex(4)}@example.invalid", password: SecureRandom.hex(8), timezone: "UTC")
      tasks = [
        [ "Wipe the kitchen sides", "kitchen", 5 ],
        [ "Load the dishwasher", "kitchen", 5 ],
        [ "Take out the recycling", "kitchen", 3 ],
        [ "Put a load of washing on", "utility", 3 ]
      ].map { |title, room, minutes| user.tasks.create!(title: title, room: room, duration_minutes: minutes, effort: "tiny") }

      recommender = Recommender.new(user: user, minutes: 30, energy: "ready", today: user.today)
      plan = AiPlanner.new(client: client).call(recommender, context: "I have half an hour and the kitchen looks awful.")
      Result.new(ok: true, plan: plan, tasks: tasks.map(&:title))
    rescue AiPlanner::Invalid, ClaudeClient::Error => e
      Result.new(ok: false, error: "#{e.class.name.demodulize}: #{e.message}")
    end
    private_class_method :run
  end
end

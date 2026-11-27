# frozen_string_literal: true

module Quests
  # Asks Claude to choose, theme and break down quests from the eligible tasks
  # the rules engine supplies. The AI suggests; this class validates every
  # field before anything is shown. Returns a Plan, or raises Invalid/Error so
  # the caller can fall back to the rules plan.
  class AiPlanner
    class Invalid < StandardError; end

    SYSTEM_PROMPT = Rails.root.join("config/game/questmaster_prompt.md").read.freeze

    TOOL = {
      name: "submit_plan",
      description: "Submit the quest plan for the player.",
      input_schema: {
        type: "object",
        required: %w[plan_title intro quests encouragement],
        properties: {
          plan_title: { type: "string" },
          intro: { type: "string" },
          quests: {
            type: "array",
            items: {
              type: "object",
              required: %w[task_id quest_title steps],
              properties: {
                task_id: { type: "integer" },
                quest_title: { type: "string" },
                steps: { type: "array", items: { type: "string" } }
              }
            }
          },
          encouragement: { type: "string" }
        }
      }
    }.freeze

    def initialize(client:)
      @client = client
    end

    def call(recommender, context:)
      eligible = recommender.eligible
      raise Invalid, "no eligible tasks" if eligible.empty?

      input = @client.call(system: SYSTEM_PROMPT, user: user_message(recommender, eligible, context), tool: TOOL)
      build_plan(input, recommender, eligible)
    end

    private
      def user_message(recommender, eligible, context)
        JSON.generate(
          available_minutes: recommender.minutes,
          usable_minutes: recommender.usable_minutes,
          max_quests: recommender.mode["max_quests"],
          energy: recommender.energy,
          energy_description: recommender.mode["description"],
          untrusted_player_context: context.to_s,
          eligible_tasks: eligible.map { |t| task_for_prompt(t) }
        )
      end

      def task_for_prompt(task)
        {
          task_id: task.id, title: task.title, room: task.room, estimated_minutes: task.duration_minutes,
          effort: task.effort, deadline: [ task.due_on, task.next_due_on ].compact.min&.iso8601,
          monster: Game::Catalog.monster(task.monster_key_or_default)["name"]
        }
      end

      def build_plan(input, recommender, eligible)
        by_id = eligible.index_by(&:id)
        raw_quests = input["quests"]
        raise Invalid, "quests missing" unless raw_quests.is_a?(Array) && raw_quests.any?
        raise Invalid, "too many quests" if raw_quests.size > recommender.mode["max_quests"]

        ids = raw_quests.map { |q| q["task_id"] }
        raise Invalid, "unknown or repeated task" if ids.uniq.size != ids.size || ids.any? { |id| !by_id.key?(id) }

        tasks = ids.map { |id| by_id.fetch(id) }
        total = tasks.sum(&:duration_minutes)
        raise Invalid, "over the time budget" if total > recommender.usable_minutes

        quests = raw_quests.zip(tasks).map do |raw, task|
          quest_hash(task, title: clean(raw["quest_title"], 80), steps: raw["steps"])
        end

        Plan.new(
          title: clean(input["plan_title"], 80).presence || FallbackText.title(recommender.energy, tasks),
          intro: clean(input["intro"], 240),
          quests: quests,
          encouragement: clean(input["encouragement"], 240),
          total_minutes: total, buffer_minutes: recommender.minutes - total,
          minutes: recommender.minutes, energy: recommender.energy, source: "ai"
        )
      end

      def quest_hash(task, title:, steps:)
        self.class.quest_hash(task, title: title, steps: Array(steps).first(5).map { |s| clean(s, 120) }.reject(&:blank?))
      end

      def clean(text, limit)
        text.to_s.gsub(/[[:cntrl:]]/, " ").squish[0, limit]
      end

      # Shared with the rules plan so both sources render identically. The real
      # task text is always the saved title, never AI-written.
      def self.quest_hash(task, title: nil, steps: [])
        {
          task_id: task.id,
          quest_title: title.presence || task.fantasy_title_or_default,
          real_task: task.title,
          steps: steps,
          estimated_minutes: task.duration_minutes,
          difficulty: TaskPresenter::DIFFICULTY.fetch(task.effort),
          monster: Game::Catalog.monster(task.monster_key_or_default)["name"],
          xp: task.xp,
          coins: task.coins
        }
      end
  end
end

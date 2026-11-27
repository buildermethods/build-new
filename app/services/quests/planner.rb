# frozen_string_literal: true

module Quests
  # Entry point for "plan my quests". Rules choose what is eligible; the AI (if
  # configured) may theme and reorder within it; anything unexpected falls back
  # to a templated rules plan, so planning never depends on the AI.
  class Planner
    CACHE_TTL = 10.minutes
    MAX_CONTEXT = 300

    # Tests (and, later, other environments) can swap the client. When nil, a
    # real client is used only if ANTHROPIC_API_KEY is set.
    cattr_accessor :client_override

    def self.call(**args)
      new(**args).call
    end

    def initialize(user:, minutes:, energy:, today:, context: "")
      @recommender = Recommender.new(user: user, minutes: minutes, energy: energy, today: today)
      @context = context.to_s.gsub(/[[:cntrl:]]/, " ").squish[0, MAX_CONTEXT]
      @user = user
    end

    def call
      client = build_client
      return rules_plan unless client

      cached = Rails.cache.read(cache_key)
      return cached if cached

      plan = AiPlanner.new(client: client).call(@recommender, context: @context)
      Rails.cache.write(cache_key, plan, expires_in: CACHE_TTL)
      plan
    rescue AiPlanner::Invalid, ClaudeClient::Error => e
      Rails.logger.warn("[Quests::Planner] falling back to rules plan: #{e.class}: #{e.message}")
      rules_plan
    end

    def rules_plan
      result = @recommender.call
      tasks = result.tasks
      Plan.new(
        title: FallbackText.title(result.energy, tasks),
        intro: FallbackText.intro(tasks),
        quests: tasks.map { |task| AiPlanner.quest_hash(task) },
        encouragement: FallbackText.encouragement(result.energy),
        total_minutes: result.total_minutes, buffer_minutes: result.buffer_minutes,
        minutes: result.minutes, energy: result.energy, source: "rules"
      )
    end

    private
      def build_client
        return self.class.client_override if self.class.client_override

        ClaudeClient.new if ClaudeClient.configured?
      end

      def cache_key
        eligible = @recommender.eligible.map { |t| [ t.id, t.updated_at.to_i ] }
        digest = Digest::SHA256.hexdigest([ @user.id, @recommender.minutes, @recommender.energy, @context, eligible ].to_json)
        "quests/ai_plan/#{digest}"
      end
  end
end

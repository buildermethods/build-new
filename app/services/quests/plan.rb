# frozen_string_literal: true

module Quests
  # A validated mini-plan ready to render. `source` is "ai" or "rules". Real
  # task text always comes from the saved Task, never from the AI.
  Plan = Struct.new(:title, :intro, :quests, :encouragement, :total_minutes, :buffer_minutes,
                    :minutes, :energy, :source, keyword_init: true) do
    def as_json(*)
      {
        title: title, intro: intro, encouragement: encouragement, source: source,
        total_minutes: total_minutes, buffer_minutes: buffer_minutes,
        minutes: minutes, energy: energy,
        quests: quests
      }
    end
  end
end

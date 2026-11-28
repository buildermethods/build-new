# frozen_string_literal: true

module Quests
  # Templated copy used when the AI is unavailable or returns something we
  # reject, so planning always works without it.
  module FallbackText
    module_function

    TITLES = {
      "survival" => "A Gentle Win",
      "gentle" => "A Gentle Adventure",
      "ready" => "Today's Quest",
      "hero" => "A Hero's Day"
    }.freeze

    ENCOURAGEMENT = {
      "survival" => "One small win counts. Rest when you need to.",
      "gentle" => "A few small wins add up, and breaks are part of the plan.",
      "ready" => "Steady steps. Every finished quest brightens the cottage.",
      "hero" => "Big energy deserves big victories. Pace yourself, hero."
    }.freeze

    def title(energy, tasks)
      first = tasks.first
      return TITLES.fetch(energy) unless first && tasks.map(&:room).uniq.size == 1 && first.room != "other"

      "The #{first.room.humanize} Rescue"
    end

    def intro(tasks)
      return "Nothing fits right now, and that is fine. Try a few more minutes or a different energy level." if tasks.empty?

      "Here #{tasks.size == 1 ? 'is one quest' : "are #{tasks.size} quests"} that fit your time."
    end

    def encouragement(energy)
      ENCOURAGEMENT.fetch(energy)
    end
  end
end

# frozen_string_literal: true

module Habits
  # Gentle "fresh start" prompts on natural reset points, plus a non-guilty
  # nudge when yesterday was quiet. Returns one message or nil.
  module FreshStart
    module_function

    def call(user, today:, welcome_back:, wins_today:)
      return { kind: "welcome_back", message: "Welcome back! Everything you earned is safe, and nothing has piled up. Start with something small whenever you like." } if welcome_back
      return { kind: "new_month", message: "A new month, a fresh start. What's one small thing you'd like to tackle first?" } if today.day == 1
      return { kind: "new_week", message: "A new week, a fresh start. Your week's progress begins again today." } if today.monday?
      return quiet_day(user, today) if wins_today.zero?

      nil
    end

    def quiet_day(user, today)
      return nil unless user.completions.active.exists?

      yesterday = today - 1
      from = user.zone.local(yesterday.year, yesterday.month, yesterday.day).beginning_of_day
      return nil if user.completions.active.where(completed_at: from...(from + 1.day)).exists?

      { kind: "tiny_win", message: "A tiny win today keeps your week on track. Two minutes is plenty." }
    end
  end
end

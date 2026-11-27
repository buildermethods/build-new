# frozen_string_literal: true

module Habits
  # Chooses "your one thing today". A task the player committed to earlier today
  # (their implementation intention) wins; otherwise the best-fitting available
  # task from the rules engine. Swapping excludes ids; "easier" steps the
  # energy level down one notch.
  class TodayPicker
    MINUTES = 30
    EASIER = { "hero" => "ready", "ready" => "gentle", "gentle" => "survival", "survival" => "survival" }.freeze

    Result = Struct.new(:task, :energy, :intention, keyword_init: true)

    def initialize(user:, today:, exclude: [], energy: "ready", easier: false)
      @user = user
      @today = today
      @exclude = Array(exclude).map(&:to_i)
      energy = "ready" unless Game::Catalog.energy_modes.key?(energy.to_s)
      @energy = easier ? EASIER.fetch(energy.to_s) : energy.to_s
      @easier = easier
    end

    def call
      intention = @user.daily_intentions.includes(:task).find_by(on_date: @today)
      if intention && !@easier && !@exclude.include?(intention.task_id) && intention.task.available_on?(@today)
        return Result.new(task: intention.task, energy: @energy, intention: intention)
      end

      recommender = Quests::Recommender.new(user: @user, minutes: MINUTES, energy: @energy, today: @today, exclude: @exclude)
      task = recommender.call.tasks.first || recommender.eligible.first
      Result.new(task: task, energy: @energy, intention: nil)
    end
  end
end

# frozen_string_literal: true

class AchievementsController < ApplicationController
  def index
    # Award anything already earned (for example by quests finished before
    # badges existed). Idempotent: each badge is created at most once.
    Achievements::Evaluator.call(Current.user)
    badges = Achievements::Evaluator.new(Current.user).progress
    render inertia: "achievements/Index", props: { badges: badges, earned_count: badges.count { |b| b[:earned] } }
  end
end

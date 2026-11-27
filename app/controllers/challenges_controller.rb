# frozen_string_literal: true

class ChallengesController < ApplicationController
  MESSAGES = {
    unknown: "That challenge doesn't exist.",
    incomplete: "Not quite there yet. No rush; it will wait for you.",
    already_claimed: "You've already claimed that one."
  }.freeze

  def claim
    result = Challenges::Claim.call(user: Current.user, period: params[:period])
    if result.ok
      flash[:notice] = "Challenge complete! +#{result.award.xp} XP, +#{result.award.coins} coins."
      Achievements::Evaluator.call(Current.user)
    else
      flash[:alert] = MESSAGES.fetch(result.error)
    end
    redirect_back fallback_location: root_path
  end
end

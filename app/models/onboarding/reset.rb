# frozen_string_literal: true

module Onboarding
  # Wipes one user's game data (tasks, routines, to-dos, battles, rewards, badges,
  # cottage and cottage rooms) and sends
  # them back through onboarding. The account itself is kept.
  class Reset
    def self.call(user:)
      User.transaction do
        user.reward_transactions.delete_all
        user.routines.destroy_all
        user.tasks.destroy_all
        user.todos.destroy_all
        user.boss_battles.destroy_all
        user.daily_intentions.delete_all
        user.user_achievements.delete_all
        user.owned_decorations.delete_all
        user.sanctuary_placements.delete_all
        # peak_level only ever rises, so reset it explicitly or locked cottage
        # rooms would stay open after a reset.
        user.progress.update!(xp: 0, coins: 0, peak_level: 1)
        user.update!(onboarded_at: nil, onboarding_draft: {})
      end
    end
  end
end

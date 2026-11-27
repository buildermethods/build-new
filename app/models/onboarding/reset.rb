# frozen_string_literal: true

module Onboarding
  # Wipes one user's game data (tasks, routines, rewards, cottage) and sends
  # them back through onboarding. The account itself is kept.
  class Reset
    def self.call(user:)
      User.transaction do
        user.reward_transactions.delete_all
        user.routines.destroy_all
        user.tasks.destroy_all
        user.owned_decorations.delete_all
        user.sanctuary_placements.delete_all
        user.progress.update!(xp: 0, coins: 0)
        user.update!(onboarded_at: nil)
      end
    end
  end
end

# frozen_string_literal: true

module Game
  # Reverses a completion's reward with a ledger entry. Rules:
  #  - nothing happens if the completion was never rewarded or already reversed;
  #  - XP and coins never go below zero. If some coins were already spent, only
  #    the remaining balance is removed, and the reversal records what was
  #    actually taken so the ledger always matches the totals.
  class UndoCompletion
    def self.call(completion)
      new(completion).call
    end

    def initialize(completion)
      @completion = completion
    end

    def call
      user = @completion.user

      PlayerProgress.transaction do
        progress = user.progress
        progress.lock!

        original = RewardTransaction.find_by(completion_id: @completion.id, kind: "completion")
        return nil unless original
        return nil if RewardTransaction.exists?(completion_id: @completion.id, kind: "reversal")

        xp = [ original.xp_delta, progress.xp ].min
        coins = [ original.coin_delta, progress.coins ].min
        begin
          RewardTransaction.transaction(requires_new: true) do
            RewardTransaction.create!(user: user, completion: @completion, kind: "reversal", xp_delta: -xp, coin_delta: -coins)
          end
        rescue ActiveRecord::RecordNotUnique
          return nil
        end

        progress.update!(xp: progress.xp - xp, coins: progress.coins - coins)
        progress
      end
    end
  end
end

# frozen_string_literal: true

module Game
  # Awards XP and coins for a completion exactly once. Safe to call repeatedly
  # (double-clicks, retries, races): a unique index on [completion_id, kind]
  # backs the guard, and totals only change in the same transaction as the
  # ledger row.
  class AwardCompletion
    Result = Struct.new(:awarded, :xp, :coins, :from_level, :to_level, :progress, keyword_init: true) do
      def leveled_up?
        to_level > from_level
      end
    end

    def self.call(completion)
      new(completion).call
    end

    def initialize(completion)
      @completion = completion
    end

    def call
      user = @completion.user
      task = @completion.task

      PlayerProgress.transaction do
        progress = user.progress
        progress.lock!
        from_level = progress.level

        return noop(progress) if RewardTransaction.exists?(completion_id: @completion.id, kind: "completion")

        xp = task.xp
        coins = task.coins
        begin
          RewardTransaction.transaction(requires_new: true) do
            RewardTransaction.create!(user: user, completion: @completion, kind: "completion", xp_delta: xp, coin_delta: coins)
          end
        rescue ActiveRecord::RecordNotUnique
          return noop(progress)
        end

        progress.update!(xp: progress.xp + xp, coins: progress.coins + coins)
        Result.new(awarded: true, xp: xp, coins: coins, from_level: from_level, to_level: progress.level, progress: progress)
      end
    end

    private
      def noop(progress)
        Result.new(awarded: false, xp: 0, coins: 0, from_level: progress.level, to_level: progress.level, progress: progress)
      end
  end
end

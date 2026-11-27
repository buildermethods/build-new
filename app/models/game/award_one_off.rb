# frozen_string_literal: true

module Game
  # Small once-only awards keyed by a reference (starting a task today, the
  # welcome bonus). A unique index on the ledger row guarantees exactly-once.
  class AwardOneOff
    Result = Struct.new(:awarded, :xp, :coins, :from_level, :to_level, keyword_init: true) do
      def leveled_up? = to_level > from_level
    end

    def self.call(user:, kind:, reference:, xp:, coins: 0)
      PlayerProgress.transaction do
        progress = user.progress
        progress.lock!
        from_level = progress.level

        return none(from_level) if RewardTransaction.exists?(user: user, kind: kind, reference: reference)

        begin
          RewardTransaction.transaction(requires_new: true) do
            RewardTransaction.create!(user: user, kind: kind, reference: reference, xp_delta: xp, coin_delta: coins)
          end
        rescue ActiveRecord::RecordNotUnique
          return none(from_level)
        end

        progress.update!(xp: progress.xp + xp, coins: progress.coins + coins)
        Result.new(awarded: true, xp: xp, coins: coins, from_level: from_level, to_level: progress.level)
      end
    end

    def self.none(level)
      Result.new(awarded: false, xp: 0, coins: 0, from_level: level, to_level: level)
    end
    private_class_method :none
  end
end

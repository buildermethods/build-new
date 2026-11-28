# frozen_string_literal: true

module Game
  # One-off bonus when every step of a routine is done on a given day. Exactly
  # once per routine per date, backed by a unique index on the ledger row.
  class AwardRoutineBonus
    Result = Struct.new(:awarded, :xp, :coins, :from_level, :to_level, keyword_init: true) do
      def leveled_up? = to_level > from_level
    end

    def self.call(routine:, date:)
      new(routine, date).call
    end

    def initialize(routine, date)
      @routine = routine
      @date = date
    end

    def call
      user = @routine.user
      reference = "#{@routine.id}:#{@date.iso8601}"
      bonus = Game::Economy.routine_bonus

      PlayerProgress.transaction do
        progress = user.progress
        progress.lock!
        from_level = progress.level

        return none(from_level) if RewardTransaction.exists?(user: user, kind: "routine_bonus", reference: reference)

        begin
          RewardTransaction.transaction(requires_new: true) do
            RewardTransaction.create!(user: user, kind: "routine_bonus", reference: reference,
                                      xp_delta: bonus[:xp], coin_delta: bonus[:coins])
          end
        rescue ActiveRecord::RecordNotUnique
          return none(from_level)
        end

        progress.update!(xp: progress.xp + bonus[:xp], coins: progress.coins + bonus[:coins])
        Result.new(awarded: true, xp: bonus[:xp], coins: bonus[:coins], from_level: from_level, to_level: progress.level)
      end
    end

    private
      def none(level)
        Result.new(awarded: false, xp: 0, coins: 0, from_level: level, to_level: level)
      end
  end
end

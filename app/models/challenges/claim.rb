# frozen_string_literal: true

module Challenges
  # Claims the reward for the current daily or weekly challenge, once. Only the
  # *current* challenge can be claimed, and only when its target is reached.
  class Claim
    Result = Struct.new(:ok, :error, :challenge, :award, keyword_init: true)

    def self.call(user:, period:)
      challenge = Current.new(user).find(period)
      return Result.new(ok: false, error: :unknown) unless challenge
      return Result.new(ok: false, error: :incomplete, challenge: challenge) unless challenge[:complete]
      return Result.new(ok: false, error: :already_claimed, challenge: challenge) if challenge[:claimed]

      award = Game::AwardOneOff.call(user: user, kind: "challenge", reference: challenge[:key],
                                     xp: challenge[:xp], coins: challenge[:coins])
      Result.new(ok: award.awarded, error: (award.awarded ? nil : :already_claimed), challenge: challenge, award: award)
    end
  end
end

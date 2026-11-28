# frozen_string_literal: true

module Game
  # Buys a cosmetic decoration with coins. Atomic and idempotent: the player's
  # progress row is locked, ownership has a unique index, and the spend is a
  # ledger row, so double-clicks and races can never charge twice.
  class PurchaseDecoration
    Result = Struct.new(:ok, :error, :decoration, keyword_init: true) do
      def ok? = ok
    end

    def self.call(user:, key:)
      new(user, key).call
    end

    def initialize(user, key)
      @user = user
      @key = key.to_s
    end

    def call
      item = Game::Catalog.decoration(@key)
      return failure(:unknown) unless item

      PlayerProgress.transaction do
        progress = @user.progress
        progress.lock!

        return failure(:already_owned) if @user.owned_decorations.exists?(decoration_key: @key)
        return failure(:insufficient_coins) if progress.coins < item["price"]

        begin
          OwnedDecoration.transaction(requires_new: true) do
            @user.owned_decorations.create!(decoration_key: @key)
            RewardTransaction.create!(user: @user, kind: "purchase", reference: @key, coin_delta: -item["price"])
          end
        rescue ActiveRecord::RecordNotUnique
          return failure(:already_owned)
        end

        progress.update!(coins: progress.coins - item["price"])
        Result.new(ok: true, decoration: item)
      end
    end

    private
      def failure(error)
        Result.new(ok: false, error: error)
      end
  end
end

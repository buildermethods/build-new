# frozen_string_literal: true

# Props for the cottage and shop. Decoration data comes from the catalog; the
# database only knows what a user owns and has equipped.
class SanctuaryPresenter
  def initialize(user)
    @user = user
  end

  def placements
    @placements ||= @user.sanctuary_placements.pluck(:slot, :decoration_key).to_h
  end

  def items
    owned = @user.owned_decorations.pluck(:decoration_key)
    equipped = placements.values
    Game::Catalog.decorations.map do |key, item|
      { key: key, name: item["name"], slot: item["slot"], price: item["price"],
        owned: owned.include?(key), equipped: equipped.include?(key) }
    end
  end

  # The cheapest decoration not yet owned, as a goal to save toward.
  def teaser
    coins = @user.progress.coins
    key, item = Game::Catalog.decorations.reject { |k, _| @user.owned_decorations.exists?(decoration_key: k) }
                             .min_by { |_, i| i["price"] }
    return nil unless item

    { key: key, name: item["name"], price: item["price"], coins_needed: [ item["price"] - coins, 0 ].max }
  end

  def as_json(*)
    { slots: Game::Catalog.decoration_slots, placements: placements, items: items, teaser: teaser }
  end
end

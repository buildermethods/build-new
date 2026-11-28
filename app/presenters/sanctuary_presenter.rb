# frozen_string_literal: true

# Props for the cottage and shop. Decoration data comes from the catalog; the
# database only knows what a user owns and has equipped, and where.
class SanctuaryPresenter
  def initialize(user)
    @user = user
  end

  # { "living_room" => { "plant" => "fern_pot" }, "kitchen" => { ... } }
  def placements
    @placements ||= @user.sanctuary_placements.pluck(:room, :slot, :decoration_key)
                         .each_with_object(Hash.new { |h, k| h[k] = {} }) { |(room, slot, key), out| out[room][slot] = key }
                         .to_h
  end

  def rooms
    peak = @user.progress.peak_level
    Game::Catalog.cottage_rooms.map do |key, room|
      { key: key, name: room["name"], unlock_level: room["unlock_level"], unlocked: peak >= room["unlock_level"] }
    end
  end

  def items
    owned = owned_keys
    placed = @user.sanctuary_placements.pluck(:decoration_key, :room).to_h
    Game::Catalog.decorations.map do |key, item|
      { key: key, name: item["name"], slot: item["slot"], price: item["price"], rooms: item["rooms"],
        owned: owned.include?(key), equipped: placed.key?(key), equipped_in: placed[key] }
    end
  end

  # The cheapest decoration not yet owned, as a goal to save toward.
  def teaser
    coins = @user.progress.coins
    key, item = Game::Catalog.decorations.reject { |k, _| owned_keys.include?(k) }
                             .min_by { |_, i| i["price"] }
    return nil unless item

    { key: key, name: item["name"], price: item["price"], coins_needed: [ item["price"] - coins, 0 ].max }
  end

  def owned_keys
    @owned_keys ||= @user.owned_decorations.pluck(:decoration_key)
  end

  def as_json(*)
    { slots: Game::Catalog.decoration_slots, rooms: rooms, placements: placements, items: items, teaser: teaser,
      level: @user.progress.level }
  end
end

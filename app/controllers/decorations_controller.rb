# frozen_string_literal: true

class DecorationsController < ApplicationController
  PURCHASE_ERRORS = {
    unknown: "That decoration doesn't exist.",
    already_owned: "You already own that.",
    insufficient_coins: "Not enough coins yet. Finish a few more quests!"
  }.freeze

  def purchase
    result = Game::PurchaseDecoration.call(user: Current.user, key: params[:key])
    if result.ok?
      redirect_to sanctuary_path, notice: "#{result.decoration['name']} is yours. Equip it to place it in the cottage."
    else
      redirect_to sanctuary_path, alert: PURCHASE_ERRORS.fetch(result.error)
    end
  end

  def equip
    if Sanctuary::Equip.call(user: Current.user, key: params[:key], room: params[:room])
      redirect_to sanctuary_path
    else
      redirect_to sanctuary_path, alert: "That can't go there. It needs to be owned, suit the room, and the room must be unlocked."
    end
  end

  def unequip
    Sanctuary::Equip.clear(user: Current.user, slot: params[:slot], room: params[:room])
    redirect_to sanctuary_path
  end
end

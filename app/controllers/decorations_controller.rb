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
    if Sanctuary::Equip.call(user: Current.user, key: params[:key])
      redirect_to sanctuary_path
    else
      redirect_to sanctuary_path, alert: "You can only place decorations you own."
    end
  end

  def unequip
    Sanctuary::Equip.clear(user: Current.user, slot: params[:slot])
    redirect_to sanctuary_path
  end
end

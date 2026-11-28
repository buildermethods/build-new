# frozen_string_literal: true

# Private before/after photos for a boss battle. Served only to the owner,
# through this controller (no public Active Storage URLs), as images only.
class BossPhotosController < ApplicationController
  before_action :set_battle_and_slot

  def show
    attachment = @battle.photo(@slot)
    return head(:not_found) unless attachment&.attached? && BossBattle::PHOTO_TYPES.include?(attachment.blob.content_type)

    response.headers["Cache-Control"] = "private, max-age=3600"
    send_data attachment.download, type: attachment.blob.content_type, disposition: "inline"
  end

  def create
    problem = BossBattle.photo_problem(params[:photo])
    return redirect_to(boss_battle_path(@battle), alert: problem) if problem

    @battle.photo(@slot).attach(params[:photo])
    # Active Storage identifies the real type from the bytes; trust that, not the
    # declared one.
    unless BossBattle::PHOTO_TYPES.include?(@battle.photo(@slot).blob.content_type)
      @battle.photo(@slot).purge
      return redirect_to(boss_battle_path(@battle), alert: "Photos must be JPG, PNG or WebP.")
    end

    redirect_to boss_battle_path(@battle), notice: "#{@slot.capitalize} photo saved. Only you can see it."
  end

  def destroy
    @battle.photo(@slot)&.purge
    redirect_to boss_battle_path(@battle)
  end

  private
    def set_battle_and_slot
      @battle = Current.user.boss_battles.find(params[:boss_battle_id])
      @slot = params[:slot].to_s
      head :not_found unless BossBattle::PHOTO_SLOTS.include?(@slot)
    end
end

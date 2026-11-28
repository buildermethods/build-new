# frozen_string_literal: true

class BossStagesController < ApplicationController
  before_action :set_stage

  def complete
    return redirect_to(boss_battle_path(@battle), alert: "Finish that chore to clear this stage.") if @stage.linked?

    result = @battle.complete_stage!(@stage)
    if result&.defeated
      flash[:victory] = defeat_payload(result, Achievements::Evaluator.call(Current.user))
    elsif result
      flash[:notice] = "Stage cleared! #{@battle.reload.health_remaining} HP left."
    end
    redirect_to boss_battle_path(@battle)
  end

  def uncomplete
    return redirect_to(boss_battle_path(@battle)) if @stage.linked?

    @battle.uncomplete_stage!(@stage)
    redirect_to boss_battle_path(@battle)
  end

  private
    def set_stage
      @battle = Current.user.boss_battles.find(params[:boss_battle_id])
      @stage = @battle.stages.find(params[:id])
    end

    def defeat_payload(result, badges)
      level_before = [ result.stage_award, result.defeat_award ].compact.first.from_level
      level = Current.user.progress.reload.level
      monster = Game::Catalog.monster(@battle.monster_key)
      {
        id: SecureRandom.random_number(1 << 30),
        monster: monster["name"], monster_key: @battle.monster_key,
        quest_title: "Boss battle", task_title: @battle.title,
        message: "Boss defeated! Every stage cleared, one at a time.",
        xp: result.xp, coins: result.coins, level: level, leveled_up: level > level_before, badges: badges
      }
    end
end

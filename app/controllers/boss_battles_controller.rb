# frozen_string_literal: true

class BossBattlesController < ApplicationController
  before_action :set_battle, only: %i[show abandon]

  def index
    battles = Current.user.boss_battles.includes(:stages).newest_first.to_a
    render inertia: "battles/Index", props: {
      active: battles.select(&:active?).map { |b| summary(b) },
      defeated: battles.select(&:defeated?).map { |b| summary(b) },
      abandoned_count: battles.count { |b| b.status == "abandoned" }
    }
  end

  def new
    render inertia: "battles/New", props: {
      templates: Game::Catalog.boss_templates.map do |key, t|
        { key: key, name: t["name"], title: t["title"], monster_key: t["monster"], stages: t["stages"] }
      end,
      monsters: Game::Catalog.monsters.map { |key, m| { key: key, name: m["name"] } },
      limits: { min: BossBattle::MIN_STAGES, max: BossBattle::MAX_STAGES }
    }
  end

  def create
    battle = BossBattle.build_for(Current.user, title: params[:title], monster_key: params[:monster_key],
                                  stage_titles: params[:stages])
    if battle.save
      redirect_to boss_battle_path(battle), notice: "Battle started. Take it one stage at a time."
    else
      redirect_back fallback_location: new_boss_battle_path,
                    inertia: { errors: battle.errors.to_hash(true).transform_values(&:first) }
    end
  end

  def show
    render inertia: "battles/Show", props: { battle: detail(@battle) }
  end

  def abandon
    @battle.abandon!
    redirect_to boss_battles_path, notice: "Battle set aside. You can start it again any time."
  end

  private
    def set_battle
      @battle = Current.user.boss_battles.includes(:stages).find(params[:id])
    end

    def summary(battle)
      {
        id: battle.id, title: battle.title, monster_key: battle.monster_key,
        monster: Game::Catalog.monster(battle.monster_key)["name"], status: battle.status,
        health_remaining: battle.health_remaining, health_total: BossBattle::TOTAL_HEALTH,
        stages_done: battle.stages.count(&:done?), stages_total: battle.stages.size,
        defeated_at: battle.defeated_at&.iso8601
      }
    end

    def detail(battle)
      summary(battle).merge(stages: battle.stages.map do |s|
        { id: s.id, title: s.title, damage: s.damage, done: s.done? }
      end)
    end
end

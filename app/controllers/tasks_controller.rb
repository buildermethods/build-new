# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[update destroy complete uncomplete skip defer start]

  def create
    task = Current.user.tasks.build(task_params)

    if task.save
      redirect_back fallback_location: quests_path, notice: "Quest added."
    else
      redirect_back_with_errors(task)
    end
  end

  def update
    if @task.update(task_params)
      redirect_back fallback_location: quests_path
    else
      redirect_back_with_errors(@task)
    end
  end

  # Tasks with history are archived so completions and (later) reward
  # transactions are preserved; tasks never completed are deleted outright.
  def destroy
    @task.completions.exists? ? @task.archive! : @task.destroy
    redirect_back fallback_location: quests_path
  end

  def complete
    completion = @task.complete!(today: Current.user.today)
    flash[:victory] = victory_payload(completion, Achievements::Evaluator.call(Current.user)) if completion&.reward&.awarded
    flash[:notice] = boss_notice(completion.boss_results) if completion&.boss_results.present?
    redirect_back fallback_location: quests_path
  end

  # Beginning counts: a small one-off XP award the first time a task is started
  # each day (the "just 2 minutes" button). Called with a raw fetch(), not
  # Inertia's router, so it returns JSON and sets no flash that a following
  # redirect could swallow.
  def start
    user = Current.user
    result = Game::AwardOneOff.call(user: user, kind: "start", reference: "#{@task.id}:#{user.today.iso8601}",
                                    xp: Game::Economy.start_xp)
    render json: { awarded: result.awarded, xp: result.xp }
  end

  def uncomplete
    @task.uncomplete!
    redirect_back fallback_location: quests_path
  end

  def skip
    @task.skip!(today: Current.user.today)
    redirect_back fallback_location: quests_path
  end

  def defer
    today = Current.user.today
    days = params.fetch(:days, 1).to_i.clamp(1, 30)
    @task.defer!(until_date: today + days)
    redirect_back fallback_location: quests_path
  end

  private
    def set_task
      @task = Current.user.tasks.find(params[:id])
    end

    # "Boss stage cleared" news when a chore was also a stage of a boss battle.
    def boss_notice(results)
      results.map do |battle, result|
        if result.defeated
          "#{battle.title} defeated! +#{result.xp} XP and +#{result.coins} coins for clearing every stage."
        else
          "Boss stage cleared: #{battle.title} has #{battle.reload.health_remaining} HP left."
        end
      end.join(" ")
    end

    def task_params
      params.permit(:title, :notes, :room, :category, :duration_minutes, :effort, :priority,
                    :due_on, :recurrence_kind, :recurrence_interval_days, :monster_key,
                    recurrence_weekdays: [])
    end

    def victory_payload(completion, badges)
      reward = completion.reward
      first = Current.user.completions.active.count == 1
      {
        id: completion.id,
        monster: Game::Catalog.monster(@task.monster_key_or_default)["name"],
        monster_key: @task.monster_key_or_default,
        quest_title: @task.fantasy_title_or_default,
        task_title: @task.title,
        message: Habits::Messages.victory(task: @task, completion: completion, first: first, leveled_up: reward.leveled_up?),
        xp: reward.xp,
        coins: reward.coins,
        level: reward.to_level,
        leveled_up: reward.leveled_up?,
        badges: badges
      }
    end

    def redirect_back_with_errors(task)
      redirect_back(fallback_location: quests_path,
                    inertia: { errors: task.errors.to_hash(true).transform_values(&:first) })
    end
end

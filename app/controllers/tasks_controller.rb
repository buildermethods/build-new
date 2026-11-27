# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[update destroy complete uncomplete skip defer]

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
    flash[:victory] = victory_payload(completion) if completion&.reward&.awarded
    redirect_back fallback_location: quests_path
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

    def task_params
      params.permit(:title, :notes, :room, :category, :duration_minutes, :effort, :priority,
                    :due_on, :recurrence_kind, :recurrence_interval_days, :monster_key,
                    recurrence_weekdays: [])
    end

    def victory_payload(completion)
      reward = completion.reward
      {
        id: completion.id,
        monster: Game::Catalog.monster(@task.monster_key_or_default)["name"],
        quest_title: @task.fantasy_title_or_default,
        task_title: @task.title,
        xp: reward.xp,
        coins: reward.coins,
        level: reward.to_level,
        leveled_up: reward.leveled_up?
      }
    end

    def redirect_back_with_errors(task)
      redirect_back(fallback_location: quests_path,
                    inertia: { errors: task.errors.to_hash(true).transform_values(&:first) })
    end
end

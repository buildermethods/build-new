# frozen_string_literal: true

class RoutinesController < ApplicationController
  include RoutineVictory

  before_action :set_routine, only: %i[update destroy complete_all]

  def index
    user = Current.user
    today = user.today
    routines = user.routines.includes(steps: :task).order(:name).to_a

    render inertia: "routines/Index", props: {
      routines: routines.map { |r| routine_json(r, today) },
      task_options: user.tasks.pending.order(:title).map { |t| { id: t.id, title: t.title } }
    }
  end

  def create
    routine = Current.user.routines.build(routine_params)
    save_with_steps(routine)
  end

  def update
    @routine.assign_attributes(routine_params)
    save_with_steps(@routine)
  end

  def destroy
    @routine.destroy
    redirect_to routines_path
  end

  # Ticks every remaining step for today.
  def complete_all
    today = Current.user.today
    level_before = Current.user.progress.level
    done = @routine.steps_done_on(today)
    results = @routine.steps.reject { |s| done.include?(s.id) }.map do |step|
      Routines::CompleteStep.call(step: step, today: today)
    end
    task_completion = results.filter_map(&:task_completion).find { |c| c.reward&.awarded }
    bonus = results.filter_map(&:bonus).first
    flash_routine_victory(routine: @routine, level_before: level_before, task_completion: task_completion, bonus: bonus)
    redirect_to routines_path
  end

  private
    def set_routine
      @routine = Current.user.routines.find(params[:id])
    end

    def routine_params
      params.permit(:name, weekdays: [])
    end

    def steps_param
      Array(params[:steps]).map { |s| s.permit(:id, :title, :task_id).to_h.symbolize_keys }
                           .reject { |s| s[:title].blank? && s[:task_id].blank? }
    end

    def save_with_steps(routine)
      Routine.transaction do
        routine.save!
        routine.replace_steps!(steps_param)
      end
      redirect_to routines_path
    rescue ActiveRecord::RecordInvalid => e
      redirect_back(fallback_location: routines_path,
                    inertia: { errors: e.record.errors.to_hash(true).transform_values(&:first) })
    end

    def routine_json(routine, today)
      done = routine.steps_done_on(today)
      {
        id: routine.id,
        name: routine.name,
        weekdays: routine.weekdays,
        scheduled_today: routine.scheduled_on?(today),
        steps: routine.steps.map do |s|
          { id: s.id, title: s.title, task_id: s.task_id, done_today: done.include?(s.id) }
        end,
        done_count: done.size,
        total: routine.steps.size
      }
    end
end

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
      templates: Game::Catalog.routine_templates.map { |key, t| { key: key, name: t["name"], blurb: t["blurb"], added: routines.any? { |r| r.name == t["name"] } } },
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

  # One-click starter routines from config/game/routine_templates.yml. Adding
  # the same one twice just takes you back to the list.
  def from_template
    template = Game::Catalog.routine_templates[params[:key].to_s]
    return redirect_to(routines_path) unless template
    return redirect_to(routines_path, notice: "#{template['name']} is already on your list.") if Current.user.routines.exists?(name: template["name"])

    Routine.transaction do
      routine = Current.user.routines.create!(name: template["name"], weekdays: template["weekdays"])
      routine.replace_steps!(template["steps"].map { |title| { title: title } })
    end
    redirect_to routines_path, notice: "Added #{template['name']}. Edit it any time."
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
    bonus = results.filter_map(&:bonus).first
    flash_routine_victory(routine: @routine, level_before: level_before,
                          task_completions: results.filter_map(&:task_completion), bonus: bonus)
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

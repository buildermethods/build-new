# frozen_string_literal: true

class RoutineStepsController < ApplicationController
  include RoutineVictory

  before_action :set_step

  def complete
    user = Current.user
    level_before = user.progress.level
    result = Routines::CompleteStep.call(step: @step, today: user.today)
    flash_routine_victory(routine: @step.routine, level_before: level_before,
                          task_completions: [ result.task_completion ].compact, bonus: result.bonus)
    redirect_back fallback_location: routines_path
  end

  def uncomplete
    Routines::CompleteStep.undo(step: @step, today: Current.user.today)
    redirect_back fallback_location: routines_path
  end

  private
    def set_step
      routine = Current.user.routines.find(params[:routine_id])
      @step = routine.steps.find(params[:id])
    end
end

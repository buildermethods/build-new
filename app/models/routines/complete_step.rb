# frozen_string_literal: true

module Routines
  # Ticks a routine step for a day. If the step is linked to a task, the task is
  # completed through the normal path (so its XP is awarded once, by the game
  # engine). When the last step of the day is ticked, the routine bonus is
  # awarded once. Ticking twice, or untick-then-retick, never pays twice.
  class CompleteStep
    Result = Struct.new(:task_completion, :bonus, :routine_done, keyword_init: true)

    def self.call(step:, today:)
      new(step, today).call
    end

    def initialize(step, today)
      @step = step
      @today = today
    end

    def call
      routine = @step.routine
      task_completion = nil

      RoutineStepCompletion.transaction do
        begin
          RoutineStepCompletion.transaction(requires_new: true) do
            RoutineStepCompletion.create!(routine_step: @step, on_date: @today)
          end
        rescue ActiveRecord::RecordNotUnique
          # Already ticked today: nothing more to award.
          return Result.new(routine_done: done?(routine))
        end

        task_completion = @step.task&.complete!(today: @today)
      end

      bonus = done?(routine) ? Game::AwardRoutineBonus.call(routine: routine, date: @today) : nil
      Result.new(task_completion: task_completion, bonus: bonus&.awarded ? bonus : nil, routine_done: done?(routine))
    end

    def self.undo(step:, today:)
      step.completions.where(on_date: today).destroy_all
    end

    private
      def done?(routine)
        routine.steps.reload.any? && routine.steps_done_on(@today).size == routine.steps.size
      end
  end
end

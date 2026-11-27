# frozen_string_literal: true

# Builds the one-time "victory" flash after routine steps are ticked, merging
# any task XP earned with the routine bonus.
module RoutineVictory
  private
    def flash_routine_victory(routine:, level_before:, task_completion:, bonus:)
      xp = coins = 0
      if task_completion&.reward&.awarded
        xp += task_completion.reward.xp
        coins += task_completion.reward.coins
      end
      if bonus
        xp += bonus.xp
        coins += bonus.coins
      end
      return if xp.zero? && coins.zero?

      level = Current.user.progress.reload.level
      flash[:victory] = {
        id: SecureRandom.random_number(1 << 30),
        monster: bonus ? routine.name : Game::Catalog.monster(task_completion.task.monster_key_or_default)["name"],
        quest_title: bonus ? "Routine complete" : task_completion.task.fantasy_title_or_default,
        task_title: bonus ? "Every step of #{routine.name}" : task_completion.task.title,
        xp: xp, coins: coins, level: level, leveled_up: level > level_before,
        monster_key: bonus ? nil : task_completion.task.monster_key_or_default,
        message: bonus ? "Every step done! A whole routine, finished." : Habits::Messages.victory(
          task: task_completion.task, completion: task_completion, first: false, leveled_up: level > level_before
        ),
        badges: Achievements::Evaluator.call(Current.user)
      }
    end
end

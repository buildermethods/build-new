# frozen_string_literal: true

module Game
  # Tiny XP for ticking a to-do: once per to-do, and at most
  # Economy.todo_daily_cap rewarded to-dos per day.
  class AwardTodo
    def self.call(user:, todo:)
      today = user.today
      from = user.zone.local(today.year, today.month, today.day).beginning_of_day
      rewarded_today = user.reward_transactions.where(kind: "todo", created_at: from...(from + 1.day)).count
      return nil if rewarded_today >= Game::Economy.todo_daily_cap

      result = AwardOneOff.call(user: user, kind: "todo", reference: "todo:#{todo.id}", xp: Game::Economy.todo_xp)
      result.awarded ? result : nil
    end
  end
end

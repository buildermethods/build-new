# frozen_string_literal: true

class QuestsController < ApplicationController
  HISTORY_LIMIT = 10

  def index
    user = Current.user
    today = user.today
    tasks = user.tasks.pending.newest_first.to_a
    available, upcoming = tasks.partition { |task| task.available_on?(today) }

    render inertia: "quests/Index", props: {
      quests: available.map { |task| TaskPresenter.new(task, today: today).as_json },
      upcoming: upcoming.map { |task| TaskPresenter.new(task, today: today).as_json },
      history: history_for(user),
      options: {
        rooms: Task::ROOMS, categories: Task::CATEGORIES, efforts: Task::EFFORTS,
        priorities: Task::PRIORITIES, recurrence_kinds: Task::RECURRENCE_KINDS
      }
    }
  end

  private
    def history_for(user)
      user.completions.active.includes(:task).newest_first.limit(HISTORY_LIMIT).map do |completion|
        {
          id: completion.id,
          task_id: completion.task_id,
          title: completion.task.title,
          completed_at: completion.completed_at.iso8601,
          xp: completion.task.xp,
          coins: completion.task.coins
        }
      end
    end
end

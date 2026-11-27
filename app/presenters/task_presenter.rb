# frozen_string_literal: true

# Turns a Task into the hash the Quest Board renders. Fantasy names always
# travel alongside the plain-language title so the real action stays visible.
class TaskPresenter
  DIFFICULTY = { "tiny" => "Easy", "small" => "Easy", "medium" => "Medium", "large" => "Hard", "boss" => "Boss" }.freeze

  def initialize(task, today:)
    @task = task
    @today = today
  end

  def as_json(*)
    monster_key = @task.monster_key_or_default
    {
      id: @task.id,
      title: @task.title,
      notes: @task.notes,
      room: @task.room,
      category: @task.category,
      duration_minutes: @task.duration_minutes,
      effort: @task.effort,
      difficulty: DIFFICULTY.fetch(@task.effort),
      priority: @task.priority,
      due_on: @task.due_on&.iso8601,
      next_due_on: @task.next_due_on&.iso8601,
      deferred_until: @task.deferred_until&.iso8601,
      recurrence_kind: @task.recurrence_kind,
      recurrence_interval_days: @task.recurrence_interval_days,
      recurrence_weekdays: @task.recurrence_weekdays,
      status: @task.status,
      available: @task.available_on?(@today),
      fantasy_title: @task.fantasy_title_or_default,
      monster: { key: monster_key, name: Game::Catalog.monster(monster_key)["name"] },
      xp: @task.xp,
      coins: @task.coins
    }
  end
end

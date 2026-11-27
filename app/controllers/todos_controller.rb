# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[update destroy complete uncomplete]

  def index
    todos = Current.user.todos.newest_first.to_a
    render inertia: "todos/Index", props: {
      open: todos.reject(&:done?).map { |t| todo_json(t) },
      done: todos.select(&:done?).first(20).map { |t| todo_json(t) },
      daily_cap: Game::Economy.todo_daily_cap
    }
  end

  def create
    todo = Current.user.todos.build(params.permit(:title))
    return redirect_back(fallback_location: todos_path) if todo.save

    redirect_back fallback_location: todos_path, inertia: { errors: todo.errors.to_hash(true).transform_values(&:first) }
  end

  def update
    return redirect_back(fallback_location: todos_path) if @todo.update(params.permit(:title))

    redirect_back fallback_location: todos_path, inertia: { errors: @todo.errors.to_hash(true).transform_values(&:first) }
  end

  def destroy
    @todo.destroy
    redirect_back fallback_location: todos_path
  end

  def complete
    result = @todo.complete!
    flash[:notice] = "Done! +#{result.xp} XP" if result
    redirect_back fallback_location: todos_path
  end

  def uncomplete
    @todo.uncomplete!
    redirect_back fallback_location: todos_path
  end

  private
    def set_todo
      @todo = Current.user.todos.find(params[:id])
    end

    def todo_json(todo)
      { id: todo.id, title: todo.title, done: todo.done?, completed_at: todo.completed_at&.iso8601 }
    end
end

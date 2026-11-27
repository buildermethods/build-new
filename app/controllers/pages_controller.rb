# frozen_string_literal: true

class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    return render inertia: "Home" unless authenticated?

    render inertia: "Todos", props: { todos: Current.user.todos.newest_first.map { |todo| todo_summary(todo) } }
  end

  private
    def todo_summary(todo)
      {
        id: todo.id,
        description: todo.description,
        completed: todo.completed,
        created_at: todo.created_at.iso8601
      }
    end
end

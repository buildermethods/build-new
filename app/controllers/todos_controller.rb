# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :set_todo, only: %i[update destroy]

  def create
    todo = Current.user.todos.build(todo_params)

    if todo.save
      redirect_to root_path
    else
      redirect_back_with_errors(todo)
    end
  end

  def update
    if @todo.update(todo_params)
      redirect_to root_path
    else
      redirect_back_with_errors(@todo)
    end
  end

  def destroy
    @todo.destroy
    redirect_to root_path
  end

  private
    def set_todo
      @todo = Current.user.todos.find(params[:id])
    end

    def todo_params
      params.permit(:description, :completed)
    end

    def redirect_back_with_errors(todo)
      redirect_back(fallback_location: root_path,
                    inertia: { errors: todo.errors.to_hash(true).transform_values(&:first) })
    end
end

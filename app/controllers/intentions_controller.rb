# frozen_string_literal: true

# "When will you do it?" - commit one task to a moment today (an implementation
# intention). One per day; choosing again replaces it.
class IntentionsController < ApplicationController
  def create
    task = Current.user.tasks.find(params[:task_id])
    intention = Current.user.daily_intentions.find_or_initialize_by(on_date: Current.user.today)
    intention.assign_attributes(task: task, anchor: params[:anchor].presence)

    if intention.save
      redirect_back fallback_location: root_path, notice: "Planned. You've got this."
    else
      redirect_back fallback_location: root_path,
                    inertia: { errors: intention.errors.to_hash(true).transform_values(&:first) }
    end
  end

  def destroy
    Current.user.daily_intentions.where(on_date: Current.user.today).destroy_all
    redirect_back fallback_location: root_path
  end
end

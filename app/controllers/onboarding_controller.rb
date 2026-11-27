# frozen_string_literal: true

class OnboardingController < ApplicationController
  before_action :redirect_if_onboarded

  def show
    render inertia: "onboarding/Show", props: {
      starter_tasks: Game::Catalog.starter_tasks.map do |t|
        t.slice("key", "title", "room", "duration_minutes", "effort").symbolize_keys
      end
    }
  end

  def create
    Onboarding::Complete.call(user: Current.user, task_keys: params[:task_keys], display_name: params[:display_name])
    redirect_to root_path(just: 1, minutes: 15, energy: "gentle"),
                notice: "Welcome! A fern now sits in your cottage. Here is a first quest to try."
  end

  def skip
    Onboarding::Complete.call(user: Current.user, task_keys: [], display_name: nil)
    redirect_to root_path
  end

  private
    def redirect_if_onboarded
      redirect_to root_path if Current.user.onboarded?
    end
end

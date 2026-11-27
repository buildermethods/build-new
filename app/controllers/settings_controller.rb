# frozen_string_literal: true

class SettingsController < ApplicationController
  def show
    render inertia: "Settings", props: {
      settings: { display_name: Current.user.display_name, reduced_motion: Current.user.reduced_motion }
    }
  end

  def update
    if Current.user.update(params.permit(:display_name, :reduced_motion))
      redirect_to settings_path, notice: "Settings saved."
    else
      redirect_to settings_path,
                  inertia: { errors: Current.user.errors.to_hash(true).transform_values(&:first) }
    end
  end

  def reset
    Onboarding::Reset.call(user: Current.user)
    redirect_to welcome_path, notice: "Your game data was reset. Let's start fresh."
  end
end

class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to signup_path, alert: "Try again later." }

  def new
    render inertia: "auth/Signup"
  end

  def create
    user = User.new(registration_params)

    if user.save
      start_new_session_for(user)
      redirect_to dashboard_path
    else
      redirect_to signup_path, inertia: { errors: user.errors.to_hash(true).transform_values(&:first) }
    end
  end

  private
    def registration_params
      params.permit(:email, :password, :timezone)
    end
end

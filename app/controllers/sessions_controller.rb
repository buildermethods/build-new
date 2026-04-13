class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to login_path, alert: "Try again later." }

  def new
    render inertia: "auth/Login"
  end

  def create
    if user = User.authenticate_by(params.permit(:email, :password))
      start_new_session_for(user)
      redirect_to after_authentication_url
    else
      redirect_to login_path, inertia: { errors: { base: "Invalid email or password." } }
    end
  end

  def destroy
    terminate_session
    redirect_to login_path
  end
end

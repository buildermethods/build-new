class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
    render inertia: "auth/PasswordNew"
  end

  def create
    if user = User.find_by(email: params[:email])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to login_path, notice: "Password reset instructions sent (if an account with that email exists)."
  end

  def edit
    render inertia: "auth/PasswordEdit", props: { token: params[:token] }
  end

  def update
    if @user.update(params.permit(:password))
      redirect_to login_path, notice: "Password has been reset. You can sign in now."
    else
      redirect_to edit_password_path(params[:token]),
                  inertia: { errors: @user.errors.to_hash(true).transform_values(&:first) }
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end

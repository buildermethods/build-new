class ProfilesController < ApplicationController
  def details
    render inertia: "profile/Details"
  end

  def password
    render inertia: "profile/Password"
  end

  def update_email
    if Current.user.update(params.permit(:email))
      redirect_to profile_path, notice: "Email updated."
    else
      redirect_to profile_path,
                  inertia: { errors: Current.user.errors.to_hash(true).transform_values(&:first) }
    end
  end

  def update_password
    user = Current.user

    unless user.authenticate(params[:current_password])
      return redirect_to profile_password_path,
                         inertia: { errors: { current_password: "is incorrect" } }
    end

    if user.update(params.permit(:password))
      redirect_to profile_password_path, notice: "Password updated."
    else
      redirect_to profile_password_path,
                  inertia: { errors: user.errors.to_hash(true).transform_values(&:first) }
    end
  end
end

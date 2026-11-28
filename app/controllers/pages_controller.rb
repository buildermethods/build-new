# frozen_string_literal: true

class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    return render inertia: "Home" unless authenticated?
    return redirect_to(welcome_path) unless Current.user.onboarded?

    render inertia: "Dashboard", props: Habits::Today.new(user: Current.user, params: params).props
  end
end

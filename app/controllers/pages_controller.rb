# frozen_string_literal: true

class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    return render inertia: "Home" unless authenticated?

    render inertia: "Dashboard", props: {
      available_count: Current.user.tasks.available_on(Current.user.today).count
    }
  end
end

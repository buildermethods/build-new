# frozen_string_literal: true

# /dashboard is the template's old home URL. Today now lives at the root, so
# keep old bookmarks working by redirecting there.
class DashboardController < ApplicationController
  def show
    redirect_to root_path
  end
end

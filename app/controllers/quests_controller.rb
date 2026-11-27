# frozen_string_literal: true

class QuestsController < ApplicationController
  def index
    render inertia: "quests/Index"
  end
end

# frozen_string_literal: true

class RoutinesController < ApplicationController
  def index
    render inertia: "routines/Index"
  end
end

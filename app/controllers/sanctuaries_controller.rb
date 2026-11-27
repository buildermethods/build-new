# frozen_string_literal: true

class SanctuariesController < ApplicationController
  def show
    render inertia: "sanctuary/Show"
  end
end

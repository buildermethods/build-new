# frozen_string_literal: true

class PlansController < ApplicationController
  def show
    render inertia: "plan/Show", props: Quests::PlanPage.new(user: Current.user, params: params).props
  end
end

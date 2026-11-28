# frozen_string_literal: true

class InsightsController < ApplicationController
  def index
    render inertia: "insights/Index", props: { insights: Habits::Insights.call(Current.user) }
  end
end

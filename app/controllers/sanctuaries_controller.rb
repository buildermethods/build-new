# frozen_string_literal: true

class SanctuariesController < ApplicationController
  def show
    render inertia: "sanctuary/Show", props: { sanctuary: SanctuaryPresenter.new(Current.user).as_json }
  end
end

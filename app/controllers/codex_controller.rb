# frozen_string_literal: true

class CodexController < ApplicationController
  def index
    entries = Codex::Entries.call(Current.user)
    render inertia: "codex/Index", props: {
      monsters: entries,
      discovered: entries.count { |e| e[:discovered] },
      total: entries.size
    }
  end
end

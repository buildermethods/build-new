# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :task
  belongs_to :user

  scope :active, -> { where(undone_at: nil) }
  scope :newest_first, -> { order(completed_at: :desc, id: :desc) }

  def undone?
    undone_at.present?
  end
end

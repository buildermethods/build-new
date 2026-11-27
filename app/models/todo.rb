# frozen_string_literal: true

class Todo < ApplicationRecord
  belongs_to :user

  validates :description, presence: true, length: { maximum: 500 }

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }
end

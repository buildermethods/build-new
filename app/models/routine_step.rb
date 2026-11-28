# frozen_string_literal: true

class RoutineStep < ApplicationRecord
  belongs_to :routine
  belongs_to :task, optional: true
  has_many :completions, class_name: "RoutineStepCompletion", dependent: :destroy

  before_validation { self.title = task.title if title.blank? && task }

  validates :title, presence: true, length: { maximum: 120 }
end

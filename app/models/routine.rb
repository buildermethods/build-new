# frozen_string_literal: true

# An ordered checklist that repeats on chosen weekdays (none chosen = every
# day). Steps may be linked to real tasks; ticking those completes the task.
class Routine < ApplicationRecord
  belongs_to :user
  has_many :steps, -> { order(:position, :id) }, class_name: "RoutineStep", dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validate :weekdays_valid

  before_validation { self.weekdays = Array(weekdays).reject(&:blank?).map(&:to_i).uniq.sort }

  def scheduled_on?(date)
    weekdays.empty? || weekdays.include?(date.wday)
  end

  # Replaces the step list, keeping existing steps (and their history) when an
  # id is supplied. `list` is an array of { id:, title:, task_id: } hashes.
  def replace_steps!(list)
    transaction do
      kept = []
      list.each_with_index do |attrs, index|
        step = attrs[:id].present? ? steps.find(attrs[:id]) : steps.build
        step.assign_attributes(title: attrs[:title], task: task_for(attrs[:task_id]), position: index)
        step.save!
        kept << step.id
      end
      steps.where.not(id: kept).destroy_all
    end
  end

  def steps_done_on(date)
    RoutineStepCompletion.where(routine_step_id: steps.map(&:id), on_date: date).pluck(:routine_step_id)
  end

  private
    def task_for(task_id)
      task_id.present? ? user.tasks.find(task_id) : nil
    end

    def weekdays_valid
      errors.add(:weekdays, "must be days of the week") if weekdays.any? { |d| !(0..6).cover?(d) }
    end
end

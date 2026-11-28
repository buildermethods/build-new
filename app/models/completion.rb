# frozen_string_literal: true

class Completion < ApplicationRecord
  belongs_to :task
  belongs_to :user
  has_many :reward_transactions, dependent: :destroy

  # Set by Task#complete! so callers can show the victory without a re-query.
  attr_accessor :reward, :boss_results

  scope :active, -> { where(undone_at: nil) }
  scope :newest_first, -> { order(completed_at: :desc, id: :desc) }

  def undone?
    undone_at.present?
  end
end

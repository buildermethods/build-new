# frozen_string_literal: true

# Append-only ledger of every XP/coin change. PlayerProgress holds the running
# totals; this table is the audit trail and the exactly-once guard.
class RewardTransaction < ApplicationRecord
  KINDS = %w[completion reversal purchase].freeze

  belongs_to :user
  belongs_to :completion, optional: true

  validates :kind, inclusion: { in: KINDS }
end

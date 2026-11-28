# frozen_string_literal: true

# A named person in the home ("Sam", "Mum") that chores can be assigned to or
# rotated between. They share the one account: there is no separate login.
class HouseholdMember < ApplicationRecord
  MAX_PER_USER = 8

  belongs_to :user
  has_many :tasks, foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify

  validates :name, presence: true, length: { maximum: 40 }
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
  validate :within_limit, on: :create

  before_validation { self.name = name.to_s.squish }
  before_create { self.position = (user.household_members.maximum(:position) || -1) + 1 }

  private
    def within_limit
      errors.add(:base, "A household can have up to #{MAX_PER_USER} people") if user && user.household_members.count >= MAX_PER_USER
    end
end

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :completions, dependent: :destroy
  has_one :player_progress, dependent: :destroy
  has_many :reward_transactions, dependent: :destroy
  has_many :routines, dependent: :destroy
  has_many :owned_decorations, dependent: :destroy
  has_many :sanctuary_placements, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 7 }, allow_nil: true
  validates :display_name, length: { maximum: 40 }

  def onboarded?
    onboarded_at.present?
  end

  def greeting_name
    display_name.presence || "adventurer"
  end

  # Running XP/coin totals, created on first use.
  def progress
    player_progress || create_player_progress!
  rescue ActiveRecord::RecordNotUnique
    reload_player_progress
  end

  # The user's current calendar date in their own timezone (falls back to UTC).
  def today
    zone = ActiveSupport::TimeZone[timezone.to_s] || ActiveSupport::TimeZone["UTC"]
    zone.today
  end
end

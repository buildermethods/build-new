# frozen_string_literal: true

# A big job split into stages. Clearing a stage deals damage; clearing them all
# defeats the boss. Progress is saved between sessions and can be left for
# later with no penalty.
class BossBattle < ApplicationRecord
  STATUSES = %w[active defeated abandoned].freeze
  MIN_STAGES = 3
  MAX_STAGES = 8
  TOTAL_HEALTH = 100

  belongs_to :user
  has_many :stages, -> { order(:position, :id) }, class_name: "BossStage", dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validates :status, inclusion: { in: STATUSES }
  validates :monster_key, inclusion: { in: ->(_) { Game::Catalog.monsters.keys } }
  validate :stage_count_in_range, on: :create

  before_validation { self.title = title.to_s.squish }

  scope :active, -> { where(status: "active") }
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  # Builds a battle with its stages; damage splits the 100 HP evenly (the last
  # stage takes any remainder). Returns the unsaved battle.
  def self.build_for(user, title:, monster_key:, stage_titles:)
    titles = Array(stage_titles).map { |t| t.to_s.squish }.reject(&:blank?).first(MAX_STAGES)
    battle = user.boss_battles.build(title: title, monster_key: monster_key)
    each = titles.empty? ? 0 : TOTAL_HEALTH / titles.size
    titles.each_with_index do |stage_title, index|
      damage = index == titles.size - 1 ? TOTAL_HEALTH - each * (titles.size - 1) : each
      battle.stages.build(title: stage_title, position: index, damage: damage)
    end
    battle
  end

  def health_remaining
    TOTAL_HEALTH - stages.select(&:done?).sum(&:damage)
  end

  def defeated?
    status == "defeated"
  end

  def active?
    status == "active"
  end

  Result = Struct.new(:stage_award, :defeat_award, :defeated, keyword_init: true) do
    def xp = [ stage_award, defeat_award ].compact.sum(&:xp)
    def coins = [ stage_award, defeat_award ].compact.sum(&:coins)
  end

  # Clears a stage. Awards stage XP once, and the defeat reward once if it was
  # the last stage. Returns a Result, or nil if the stage was already cleared or
  # the battle is not active.
  def complete_stage!(stage, at: Time.current)
    with_lock do
      next nil unless active? && !stage.done?

      stage.update!(completed_at: at)
      stage_award = Game::AwardOneOff.call(user: user, kind: "boss_stage", reference: "stage:#{stage.id}",
                                           xp: Game::Economy.boss_stage_xp)
      defeat_award = nil
      if stages.reload.all?(&:done?)
        update!(status: "defeated", defeated_at: at)
        reward = Game::Economy.boss_defeat
        defeat_award = Game::AwardOneOff.call(user: user, kind: "boss_defeat", reference: "battle:#{id}",
                                              xp: reward[:xp], coins: reward[:coins])
      end
      Result.new(stage_award: stage_award.awarded ? stage_award : nil,
                 defeat_award: defeat_award&.awarded ? defeat_award : nil, defeated: defeated?)
    end
  end

  # Mistakes happen: a stage can be un-ticked while the boss is still alive.
  # Nothing is clawed back, and re-clearing it never pays twice.
  def uncomplete_stage!(stage)
    with_lock do
      next nil unless active? && stage.done?

      stage.update!(completed_at: nil)
    end
  end

  def abandon!
    update!(status: "abandoned") if active?
  end

  private
    def stage_count_in_range
      count = stages.size
      errors.add(:base, "A boss battle needs #{MIN_STAGES} to #{MAX_STAGES} stages") unless (MIN_STAGES..MAX_STAGES).cover?(count)
    end
end

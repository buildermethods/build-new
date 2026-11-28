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
  PHOTO_TYPES = %w[image/jpeg image/png image/webp].freeze
  PHOTO_MAX_BYTES = 5.megabytes
  PHOTO_SLOTS = %w[before after].freeze

  has_one_attached :before_photo
  has_one_attached :after_photo
  has_many :stages, -> { order(:position, :id) }, class_name: "BossStage", dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validates :status, inclusion: { in: STATUSES }
  validates :monster_key, inclusion: { in: ->(_) { Game::Catalog.monsters.keys } }
  validate :stage_count_in_range, on: :create
  validate :photos_acceptable

  before_validation { self.title = title.to_s.squish }

  scope :active, -> { where(status: "active") }
  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  # Builds a battle with its stages; damage splits the 100 HP evenly (the last
  # stage takes any remainder). Returns the unsaved battle.
  #
  # `task_ids` stack the player's real chores into the battle: each becomes a
  # stage that clears when the chore is completed. Free-text stages follow.
  def self.build_for(user, title:, monster_key:, stage_titles: [], task_ids: [])
    ids = Array(task_ids).map(&:to_i).uniq
    tasks = user.tasks.pending.where(id: ids).sort_by { |t| ids.index(t.id) }.first(MAX_STAGES)
    free = Array(stage_titles).map { |t| t.to_s.squish }.reject(&:blank?).first(MAX_STAGES - tasks.size)
    entries = tasks.map { |t| { title: t.title.truncate(160), task: t } } + free.map { |t| { title: t, task: nil } }

    battle = user.boss_battles.build(title: title, monster_key: monster_key)
    each = entries.empty? ? 0 : TOTAL_HEALTH / entries.size
    entries.each_with_index do |entry, index|
      damage = index == entries.size - 1 ? TOTAL_HEALTH - each * (entries.size - 1) : each
      battle.stages.build(title: entry[:title], task: entry[:task], position: index, damage: damage)
    end
    battle
  end

  # Completing a chore clears its stage in every active battle. Returns
  # [battle, Result] pairs for the stages that actually cleared.
  def self.clear_linked_stages!(task, at: Time.current)
    BossStage.joins(:boss_battle).merge(active).where(task_id: task.id, completed_at: nil).includes(:boss_battle).filter_map do |stage|
      result = stage.boss_battle.complete_stage!(stage, at: at)
      [ stage.boss_battle, result ] if result
    end
  end

  # What defeating this boss pays, shown up front so the stakes are clear.
  def defeat_reward
    Game::Economy.boss_defeat(stages: stages.size)
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
        reward = defeat_reward
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

  # Why an uploaded file can't be used, or nil when it is fine.
  def self.photo_problem(file)
    return "Choose a photo first." unless file.respond_to?(:content_type) && file.respond_to?(:size)
    return "Photos must be JPG, PNG or WebP." unless PHOTO_TYPES.include?(file.content_type)
    "Photos must be under #{PHOTO_MAX_BYTES / 1.megabyte} MB." if file.size > PHOTO_MAX_BYTES
  end

  def photo(slot)
    public_send("#{slot}_photo") if PHOTO_SLOTS.include?(slot.to_s)
  end

  private
    # Photos are private to the player: small, and images only.
    def photos_acceptable
      PHOTO_SLOTS.each do |slot|
        attachment = public_send("#{slot}_photo")
        next unless attachment.attached?

        errors.add(:base, "Photos must be JPG, PNG or WebP") unless PHOTO_TYPES.include?(attachment.blob.content_type)
        errors.add(:base, "Photos must be under #{PHOTO_MAX_BYTES / 1.megabyte} MB") if attachment.blob.byte_size > PHOTO_MAX_BYTES
      end
    end

    def stage_count_in_range
      count = stages.size
      errors.add(:base, "A boss battle needs #{MIN_STAGES} to #{MAX_STAGES} stages") unless (MIN_STAGES..MAX_STAGES).cover?(count)
    end
end

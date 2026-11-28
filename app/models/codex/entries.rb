# frozen_string_literal: true

module Codex
  # Every monster with what the player has done to it. A monster is "discovered"
  # by defeating it for the first time, through a quest or a boss battle. Derived
  # from existing records, so it needs no tables of its own.
  class Entries
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      Game::Catalog.monsters.map do |key, monster|
        count = counts.fetch(key, 0)
        {
          key: key, name: monster["name"], discovered: count.positive?,
          description: monster["description"], flavor: monster["flavor"],
          defeats: count, first_defeated_on: firsts[key]&.to_date&.iso8601
        }
      end
    end

    def discovered_count
      counts.count { |_, n| n.positive? }
    end

    private
      # monster key => number of defeats (quests finished + boss battles won)
      def counts
        @counts ||= begin
          tally = Hash.new(0)
          quest_rows.each { |key, _| tally[key] += 1 }
          boss_rows.each { |key, _| tally[key] += 1 }
          tally
        end
      end

      def firsts
        @firsts ||= begin
          earliest = {}
          (quest_rows + boss_rows).each do |key, at|
            earliest[key] = at if earliest[key].nil? || at < earliest[key]
          end
          earliest
        end
      end

      # [[monster_key, time], ...] for each active completion
      def quest_rows
        @quest_rows ||= @user.completions.active.joins(:task)
                             .pluck("tasks.monster_key", "tasks.room", "tasks.category", "completions.completed_at")
                             .map do |monster_key, room, category, at|
          [ monster_key.presence || Game::Catalog.monster_key_for(room: room, category: category), at ]
        end
      end

      def boss_rows
        @boss_rows ||= @user.boss_battles.where(status: "defeated").pluck(:monster_key, :defeated_at)
      end
  end
end

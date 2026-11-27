# frozen_string_literal: true

module Onboarding
  # Turns a Draft into real tasks: one per chore per room instance, with the
  # chosen frequency mapped onto the existing recurrence engine. First due dates
  # of "every N days" chores are spread across the first two weeks so a new
  # player never meets a wall of work. Re-running skips anything already made
  # (matched on source_key), so adding chores later never duplicates.
  class Builder
    MAX_TASKS = 150
    SPREAD_DAYS = 14

    def self.call(user:, draft:, today: user.today)
      new(user, draft, today).call
    end

    def initialize(user, draft, today)
      @user = user
      @draft = draft
      @today = today
    end

    def call
      existing = @user.tasks.where.not(source_key: nil).pluck(:source_key).to_set
      created = 0
      spread_index = 0

      specs.each do |spec|
        break if created >= MAX_TASKS
        next if existing.include?(spec[:source_key])

        freq = Game::Catalog.frequency(spec[:frequency])
        attrs = spec.slice(:title, :room, :room_label, :category, :duration_minutes, :effort, :source_key)
        if freq["kind"] == "calendar"
          attrs.merge!(recurrence_kind: "calendar", recurrence_weekdays: freq["weekdays"])
        else
          attrs.merge!(recurrence_kind: "completion", recurrence_interval_days: freq["interval"],
                       next_due_on: @today + (spread_index % [ freq["interval"], SPREAD_DAYS ].min))
          spread_index += 1
        end
        @user.tasks.create!(attrs)
        created += 1
      end
      created
    end

    private
      def specs
        @draft.rooms.flat_map do |room_key, count|
          room = Game::Catalog.chore_rooms.fetch(room_key)
          (1..count).flat_map do |instance|
            label = count > 1 ? "#{room['label']} #{instance}" : room["label"]
            room["chores"].filter_map do |chore|
              chore_key = "#{room_key}.#{chore['key']}"
              next unless @draft.chores.include?(chore_key)

              {
                source_key: "#{room_key}:#{instance}:#{chore['key']}",
                title: count > 1 ? "#{chore['title']} (#{label})" : chore["title"],
                room: room["room"], room_label: label,
                category: chore["category"] || room["category"],
                duration_minutes: chore["minutes"], effort: chore["effort"],
                frequency: @draft.frequency_for(chore_key)
              }
            end
          end
        end
      end
  end
end

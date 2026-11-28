# frozen_string_literal: true

module Quests
  # Rules engine: picks which of the user's real, available tasks fit the time
  # and energy they have. Pure selection and ranking, no AI. The AI planner only
  # ever sees what this class deems eligible.
  class Recommender
    # Windows of 10 minutes or less may be filled completely; longer windows
    # keep roughly a fifth free as a buffer.
    SHORT_WINDOW = 10
    BUFFER = 0.2

    Result = Struct.new(:tasks, :total_minutes, :usable_minutes, :buffer_minutes, :energy, :minutes, keyword_init: true)

    def initialize(user:, minutes:, energy:, today:, exclude: [])
      @user = user
      @minutes = minutes
      @energy = Game::Catalog.energy_modes.key?(energy.to_s) ? energy.to_s : "ready"
      @today = today
      @exclude = Array(exclude)
    end

    def self.usable_minutes(minutes)
      minutes <= SHORT_WINDOW ? minutes : (minutes * (1 - BUFFER)).floor
    end

    attr_reader :energy, :minutes

    def mode
      Game::Catalog.energy_mode(@energy)
    end

    def usable_minutes
      self.class.usable_minutes(@minutes)
    end

    # Tasks that may be suggested at all: available today, allowed for this
    # energy, individually short enough, not excluded. Ranked best-first.
    def eligible
      @eligible ||= @user.tasks.available_on(@today)
                         .where(effort: mode["allowed_efforts"])
                         .where.not(id: @exclude)
                         .where("duration_minutes <= ?", usable_minutes)
                         .to_a
                         .sort_by { |task| [ -score(task), task.duration_minutes, task.id ] }
    end

    def call
      picked = []
      total = 0
      eligible.each do |task|
        break if picked.size >= mode["max_quests"]
        next if total + task.duration_minutes > usable_minutes

        picked << task
        total += task.duration_minutes
      end

      Result.new(tasks: picked, total_minutes: total, usable_minutes: usable_minutes,
                 buffer_minutes: @minutes - total, energy: @energy, minutes: @minutes)
    end

    private
      def score(task)
        urgency(task) + PRIORITY_POINTS.fetch(task.priority) + effort_fit(task)
      end

      PRIORITY_POINTS = { "high" => 20, "normal" => 10, "low" => 0 }.freeze

      def urgency(task)
        deadline = [ task.due_on, task.next_due_on ].compact.min
        return 5 unless deadline

        days_late = (@today - deadline).to_i
        if days_late.positive? then 30 + [ days_late, 14 ].min
        elsif days_late.zero? then 25
        elsif days_late >= -3 then 15
        else 5
        end
      end

      # Low-energy modes lean toward smaller jobs, Hero Mode toward bigger ones.
      def effort_fit(task)
        index = Task::EFFORTS.index(task.effort)
        case @energy
        when "survival", "gentle" then -index * 2
        when "hero" then index * 2
        else 0
        end
      end
  end
end

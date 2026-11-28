# frozen_string_literal: true

module Habits
  # Props for the Today screen: one clear thing to do, small visible progress,
  # and gentle, never punishing, prompts. Read-only.
  class Today
    def initialize(user:, params:)
      @user = user
      @params = params
      @today = user.today
    end

    def props
      week = WeekProgress.new(@user, today: @today)
      welcome_back = welcome_back?
      pick = TodayPicker.new(user: @user, today: @today, exclude: @params[:exclude], energy: @params[:energy].to_s,
                             easier: @params[:easier].present?).call

      {
        greeting: greeting,
        prompt: FreshStart.call(@user, today: @today, welcome_back: welcome_back, wins_today: week.wins_today),
        available_count: @user.tasks.available_on(@today).count,
        one_thing: one_thing(pick),
        week: week.as_json,
        today: week.today_json,
        identity: Messages.identity(@user, week),
        anchors: Onboarding::Complete::ANCHORS,
        default_anchor: @user.anchor,
        treat: @user.treat,
        challenges: Challenges::Current.call(@user),
        boss: active_boss,
        todos: @user.todos.open.reminders_first.limit(3).map { |t| { id: t.id, title: t.title, remind_text: t.reminder_text(@today) } },
        todo_open_count: @user.todos.open.count,
        achievements: achievements,
        sanctuary: SanctuaryPresenter.new(@user).as_json
      }
    end

    private
      def one_thing(pick)
        return { quest: nil, energy: pick.energy, intention: nil } unless pick.task

        {
          quest: TaskPresenter.new(pick.task, today: @today).as_json,
          energy: pick.energy,
          intention: pick.intention && { anchor: pick.intention.anchor }
        }
      end

      def active_boss
        battle = @user.boss_battles.active.includes(:stages).newest_first.first
        battle && { id: battle.id, title: battle.title, monster_key: battle.monster_key,
                    health_remaining: battle.health_remaining, health_total: BossBattle::TOTAL_HEALTH }
      end

      def achievements
        earned = @user.user_achievements.order(:earned_at).pluck(:key)
        earned.filter_map do |key|
          config = Game::Catalog.achievements[key]
          config && { key: key, name: config["name"], description: config["description"] }
        end
      end

      def welcome_back?
        last = @user.completions.active.maximum(:completed_at)
        last.present? && last < 7.days.ago
      end

      def greeting
        hour = Time.current.in_time_zone(@user.zone).hour
        part = hour < 12 ? "morning" : (hour < 18 ? "afternoon" : "evening")
        "Good #{part}, #{@user.greeting_name}!"
      end
  end
end

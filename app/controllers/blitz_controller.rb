# frozen_string_literal: true

# Tidy blitz: pick 5-20 minutes and get a line-up of small chores that fit,
# shortest first. Optional, no penalty for stopping early.
class BlitzController < ApplicationController
  OPTIONS = [ 5, 10, 15, 20 ].freeze

  def show
    minutes = params[:minutes].to_i
    minutes = 10 unless OPTIONS.include?(minutes)
    today = Current.user.today
    render inertia: "blitz/Show", props: {
      minutes: minutes,
      options: OPTIONS,
      queue: line_up(minutes, today).map { |t| TaskPresenter.new(t, today: today).as_json },
      treat: Current.user.treat,
      playlists: Game::Catalog.playlists.map { |p| p.slice("key", "label", "blurb", "spotify_id").symbolize_keys }
    }
  end

  # Completes one chore from the blitz. Reports with a plain notice rather than
  # the victory dialog so the sprint is not interrupted; badges still count.
  def complete
    task = Current.user.tasks.find(params[:id])
    completion = task.complete!(today: Current.user.today)
    Achievements::Evaluator.call(Current.user) if completion&.reward&.awarded
    if completion
      reward = completion.reward
      notice = reward&.awarded ? "Done! +#{reward.xp} XP, +#{reward.coins} coins." : "Done!"
      notice = "#{notice} #{boss_notice(completion.boss_results)}" if completion.boss_results.present?
      flash[:notice] = notice
    end
    redirect_to blitz_path(minutes: params[:minutes])
  end

  private
    # Shortest first until the time budget is used; always at least one chore.
    def line_up(minutes, today)
      budget = minutes
      Current.user.tasks.available_on(today).order(:duration_minutes, :id).limit(60).each_with_object([]) do |task, out|
        next if task.duration_minutes > budget && out.any?
        next if task.duration_minutes > minutes

        out << task
        budget -= task.duration_minutes
        break out if budget <= 0 || out.size >= 12
      end
    end

    def boss_notice(results)
      results.map { |battle, result| result.defeated ? "#{battle.title} defeated!" : "Boss stage cleared." }.join(" ")
    end
end

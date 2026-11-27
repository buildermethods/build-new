require "test_helper"

class Achievements::EvaluatorTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.tasks.destroy_all
    @today = @user.today
  end

  def finish(task, on: @today)
    task.update_columns(next_due_on: nil, deferred_until: nil, completed_at: nil)
    task.complete!(today: on, at: @user.zone.local(on.year, on.month, on.day, 9))
  end

  def quick_task(title = "Quick", **attrs)
    @user.tasks.create!({ title: title, duration_minutes: 3, effort: "tiny", recurrence_kind: "completion", recurrence_interval_days: 1 }.merge(attrs))
  end

  test "nothing is earned before the first quest" do
    assert_empty Achievements::Evaluator.call(@user)
  end

  test "the first completion earns First Victory exactly once" do
    finish(quick_task)
    assert_equal [ "first_victory" ], Achievements::Evaluator.call(@user).map { |b| b[:key] }
    assert_empty Achievements::Evaluator.call(@user)
    assert_equal 1, @user.user_achievements.where(key: "first_victory").count
  end

  test "ten quick quests earn Five-Minute Hero" do
    task = quick_task
    10.times { |i| finish(task, on: @today - i) }
    assert_includes Achievements::Evaluator.call(@user).map { |b| b[:key] }, "five_minute_hero"
  end

  test "category and room milestones count the right tasks" do
    task = quick_task(category: "cleaning", room: "kitchen")
    10.times { |i| finish(task, on: @today - i) }
    keys = Achievements::Evaluator.call(@user).map { |b| b[:key] }
    assert_includes keys, "goblin_slayer"
    assert_not_includes keys, "kitchen_calm"
  end

  test "four active days in a week earns Steady Week" do
    task = quick_task
    monday = @today.beginning_of_week(:monday)
    4.times { |i| finish(task, on: monday + i) }
    travel_to @user.zone.local((monday + 3).year, (monday + 3).month, (monday + 3).day, 12) do
      assert_includes Achievements::Evaluator.call(@user).map { |b| b[:key] }, "steady_week"
    end
  end

  test "finishing a quest after a week away earns Comeback Kid" do
    task = quick_task
    finish(task, on: @today - 20)
    finish(task, on: @today - 2)
    assert_includes Achievements::Evaluator.call(@user).map { |b| b[:key] }, "comeback_kid"
  end

  test "owning five decorations earns Cosy Collector" do
    @user.progress.update!(coins: 1000)
    %w[fern_pot sunny_succulent table_lamp meadow_frame woven_rug].each { |k| Game::PurchaseDecoration.call(user: @user, key: k) }
    assert_includes Achievements::Evaluator.call(@user).map { |b| b[:key] }, "cosy_collector"
  end

  test "badges are never taken away by an undo" do
    task = quick_task
    finish(task)
    Achievements::Evaluator.call(@user)
    task.uncomplete!
    Achievements::Evaluator.call(@user)
    assert @user.user_achievements.exists?(key: "first_victory")
  end

  test "every configured achievement has a known metric" do
    Game::Catalog.achievements.each do |key, config|
      assert config["name"].present? && config["description"].present?, key
      assert_match(/\A(completions|quick|week_days|comeback|decorations|category:\w+|room:\w+)\z/, config["metric"], key)
      assert_operator config["threshold"], :>=, 1
    end
  end
end

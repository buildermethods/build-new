require "test_helper"

class Quests::RecommenderTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @today = Date.new(2026, 5, 6)
    @user.tasks.destroy_all
  end

  def task(title, minutes:, effort: "tiny", **attrs)
    @user.tasks.create!({ title: title, duration_minutes: minutes, effort: effort }.merge(attrs))
  end

  def plan(minutes:, energy:, **opts)
    Quests::Recommender.new(user: @user, minutes: minutes, energy: energy, today: @today, **opts).call
  end

  test "never plans more than the usable time and leaves a buffer" do
    task("A", minutes: 5)
    task("B", minutes: 5)
    task("C", minutes: 5)
    result = plan(minutes: 20, energy: "ready") # usable 16
    assert_operator result.total_minutes, :<=, 16
    assert_equal 3, result.tasks.size
    assert_operator result.buffer_minutes, :>=, 4
  end

  test "a short window may be filled completely" do
    task("A", minutes: 5)
    assert_equal [ "A" ], plan(minutes: 5, energy: "ready").tasks.map(&:title)
  end

  test "survival mode only suggests tiny tasks and at most two" do
    task("tiny 1", minutes: 3)
    task("tiny 2", minutes: 3)
    task("tiny 3", minutes: 3)
    task("small", minutes: 5, effort: "small")
    task("big", minutes: 5, effort: "large")
    result = plan(minutes: 60, energy: "survival")
    assert result.tasks.all? { |t| t.effort == "tiny" }
    assert_equal 2, result.tasks.size
  end

  test "gentle mode excludes medium and larger tasks" do
    task("medium", minutes: 10, effort: "medium")
    task("small", minutes: 5, effort: "small")
    assert_equal [ "small" ], plan(minutes: 60, energy: "gentle").tasks.map(&:title)
  end

  test "boss tasks only appear in hero mode" do
    task("boss", minutes: 30, effort: "boss")
    assert_empty plan(minutes: 60, energy: "ready").tasks
    assert_equal [ "boss" ], plan(minutes: 60, energy: "hero").tasks.map(&:title)
  end

  test "a task longer than the window is never suggested" do
    task("long", minutes: 30, effort: "medium")
    assert_empty plan(minutes: 20, energy: "ready").tasks
  end

  test "overdue and high priority tasks rank first" do
    task("someday", minutes: 5)
    task("urgent", minutes: 5, priority: "high", due_on: @today - 2)
    assert_equal "urgent", plan(minutes: 60, energy: "ready").tasks.first.title
  end

  test "only available tasks are suggested" do
    task("deferred", minutes: 5, deferred_until: @today + 1)
    task("done", minutes: 5, completed_at: Time.current)
    task("archived", minutes: 5, status: "archived")
    task("later", minutes: 5, recurrence_kind: "completion", recurrence_interval_days: 7).update_columns(next_due_on: @today + 3)
    task("ok", minutes: 5)
    assert_equal [ "ok" ], plan(minutes: 60, energy: "ready").tasks.map(&:title)
  end

  test "excluded tasks are skipped" do
    a = task("A", minutes: 5, priority: "high")
    task("B", minutes: 5)
    assert_equal [ "B" ], plan(minutes: 60, energy: "ready", exclude: [ a.id ]).tasks.map(&:title)
  end

  test "other users' tasks are never suggested" do
    users(:two).tasks.create!(title: "Theirs", duration_minutes: 5)
    assert_empty plan(minutes: 60, energy: "ready").tasks
  end

  test "unknown energy falls back to ready" do
    assert_equal "ready", plan(minutes: 30, energy: "bogus").energy
  end

  test "low energy prefers the smaller job, hero the bigger one" do
    task("tiny", minutes: 5, effort: "tiny")
    task("large", minutes: 20, effort: "large")
    assert_equal "tiny", plan(minutes: 120, energy: "gentle").tasks.first.title
    assert_equal "large", plan(minutes: 120, energy: "hero").tasks.first.title
  end
end

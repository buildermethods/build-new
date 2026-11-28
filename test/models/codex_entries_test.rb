require "test_helper"

class CodexEntriesTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.tasks.destroy_all
    @today = @user.today
  end

  def finish(task, on: @today)
    task.update_columns(next_due_on: nil, deferred_until: nil, completed_at: nil)
    task.complete!(today: on, at: @user.zone.local(on.year, on.month, on.day, 9))
  end

  def task(room:, category: "cleaning", **attrs)
    @user.tasks.create!({ title: "Chore in #{room}", room: room, category: category, recurrence_kind: "completion", recurrence_interval_days: 1 }.merge(attrs))
  end

  def entry(key)
    Codex::Entries.call(@user).find { |e| e[:key] == key }
  end

  test "every monster starts undiscovered" do
    entries = Codex::Entries.call(@user)
    assert_equal Game::Catalog.monsters.keys, entries.map { |e| e[:key] }
    assert entries.none? { |e| e[:discovered] }
    assert entries.all? { |e| e[:defeats].zero? }
  end

  test "finishing a quest discovers its monster and counts defeats" do
    t = task(room: "kitchen")
    finish(t, on: @today - 1)
    finish(t)
    e = entry("counter_goblins")
    assert e[:discovered]
    assert_equal 2, e[:defeats]
    assert_equal (@today - 1).iso8601, e[:first_defeated_on]
    assert_not entry("toy_swarm")[:discovered]
  end

  test "an explicit monster on the task wins over the room default" do
    finish(task(room: "kitchen", monster_key: "toy_swarm"))
    assert entry("toy_swarm")[:discovered]
    assert_not entry("counter_goblins")[:discovered]
  end

  test "undone completions do not count" do
    t = task(room: "kitchen")
    finish(t)
    t.uncomplete!
    assert_not entry("counter_goblins")[:discovered]
  end

  test "a defeated boss discovers its monster, abandoned ones do not" do
    won = BossBattle.build_for(@user, title: "Won", monster_key: "wardrobe_wraith", stage_titles: %w[a b c]).tap(&:save!)
    won.stages.each { |s| won.complete_stage!(s) }
    lost = BossBattle.build_for(@user, title: "Lost", monster_key: "toy_swarm", stage_titles: %w[a b c]).tap(&:save!)
    lost.abandon!
    assert entry("wardrobe_wraith")[:discovered]
    assert_not entry("toy_swarm")[:discovered]
  end

  test "four different monsters earn Monster Hunter" do
    %w[kitchen bathroom laundry kids_room].each { |room| finish(task(room: room)) }
    assert_includes Achievements::Evaluator.call(@user).map { |b| b[:key] }, "monster_hunter"
  end

  test "other players' defeats never show" do
    other = users(:two)
    other.tasks.create!(title: "x", room: "kitchen").complete!(today: other.today)
    assert_not entry("counter_goblins")[:discovered]
  end

  test "every monster has codex text" do
    Game::Catalog.monsters.each do |key, m|
      assert m["description"].present? && m["flavor"].present?, key
    end
  end
end

require "test_helper"

class BossBattleTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  def battle(stages: %w[One Two Three Four], title: "Slay the pile", monster: "doom_pile_dragon")
    b = BossBattle.build_for(@user, title: title, monster_key: monster, stage_titles: stages)
    b.save!
    b
  end

  def xp
    PlayerProgress.find_by!(user: @user).xp
  end

  # --- building ----------------------------------------------------------------

  test "damage splits the 100 HP evenly and always totals 100" do
    [ 3, 4, 5, 6, 7, 8 ].each do |n|
      b = battle(stages: Array.new(n) { |i| "Stage #{i}" })
      assert_equal 100, b.stages.sum(&:damage), "#{n} stages"
      assert_equal 100, b.health_remaining
    end
  end

  test "needs between three and eight stages" do
    assert_not BossBattle.build_for(@user, title: "x", monster_key: "toy_swarm", stage_titles: %w[a b]).valid?
    assert BossBattle.build_for(@user, title: "x", monster_key: "toy_swarm", stage_titles: %w[a b c]).valid?
    nine = BossBattle.build_for(@user, title: "x", monster_key: "toy_swarm", stage_titles: Array.new(9) { |i| "s#{i}" })
    assert_equal 8, nine.stages.size
  end

  test "blank stages are dropped and a title and known monster are required" do
    b = BossBattle.build_for(@user, title: "x", monster_key: "toy_swarm", stage_titles: [ "a", " ", "b", "", "c" ])
    assert_equal 3, b.stages.size
    assert_not BossBattle.build_for(@user, title: " ", monster_key: "toy_swarm", stage_titles: %w[a b c]).valid?
    assert_not BossBattle.build_for(@user, title: "x", monster_key: "dragon", stage_titles: %w[a b c]).valid?
  end

  # --- fighting ----------------------------------------------------------------

  test "clearing a stage reduces health and awards stage xp once" do
    b = battle
    result = b.complete_stage!(b.stages.first)
    assert_equal 75, b.reload.health_remaining
    assert_equal 10, result.stage_award.xp
    assert_not result.defeated
    assert_equal 10, xp
  end

  test "clearing the same stage twice does nothing" do
    b = battle
    stage = b.stages.first
    b.complete_stage!(stage)
    assert_nil b.complete_stage!(stage)
    assert_equal 10, xp
  end

  test "clearing the last stage defeats the boss with the big reward, once" do
    b = battle
    results = b.stages.map { |s| b.complete_stage!(s) }
    assert results.last.defeated
    assert b.reload.defeated?
    assert b.defeated_at
    assert_equal 0, b.health_remaining
    # four stages (10 each) plus the defeat reward: 150 base + 15 per stacked stage
    assert_equal 40 + 150 + 15 * 4, xp
    assert_equal 60, PlayerProgress.find_by!(user: @user).coins
    assert_equal 1, RewardTransaction.where(kind: "boss_defeat").count
  end

  test "a defeated boss cannot be fought again" do
    b = battle
    b.stages.each { |s| b.complete_stage!(s) }
    assert_nil b.complete_stage!(b.stages.first)
    assert_equal 40 + 150 + 15 * 4, xp
  end

  test "a stage can be un-ticked while the boss lives, with no clawback and no double pay" do
    b = battle
    stage = b.stages.first
    b.complete_stage!(stage)
    b.uncomplete_stage!(stage)
    assert_equal 100, b.reload.health_remaining
    assert_equal 10, xp
    b.complete_stage!(stage.reload)
    assert_equal 10, xp
    assert_equal 1, RewardTransaction.where(kind: "boss_stage", reference: "stage:#{stage.id}").count
  end

  test "an abandoned battle keeps its progress and cannot be advanced" do
    b = battle
    b.complete_stage!(b.stages.first)
    b.abandon!
    assert_equal "abandoned", b.reload.status
    assert_equal 75, b.health_remaining
    assert_nil b.complete_stage!(b.stages.second)
  end

  test "the database refuses duplicate stage and defeat rewards" do
    b = battle
    b.stages.each { |s| b.complete_stage!(s) }
    assert_raises(ActiveRecord::RecordNotUnique) do
      RewardTransaction.create!(user: @user, kind: "boss_defeat", reference: "battle:#{b.id}", xp_delta: 1)
    end
  end

  test "defeating a boss earns Dragon Tamer" do
    b = battle
    b.stages.each { |s| b.complete_stage!(s) }
    assert_includes Achievements::Evaluator.call(@user).map { |x| x[:key] }, "dragon_tamer"
  end

  test "templates are valid battles" do
    Game::Catalog.boss_templates.each do |key, t|
      assert_includes Game::Catalog.monsters.keys, t["monster"], key
      b = BossBattle.build_for(@user, title: t["title"], monster_key: t["monster"], stage_titles: t["stages"])
      assert b.valid?, "#{key}: #{b.errors.full_messages.to_sentence}"
    end
  end

  # --- stacking real chores ----------------------------------------------------

  def chore(title)
    @user.tasks.create!(title: title)
  end

  def stacked(tasks, extra: [])
    b = BossBattle.build_for(@user, title: "Tidy up", monster_key: "doom_pile_dragon", stage_titles: extra, task_ids: tasks.map(&:id))
    b.save!
    b
  end

  test "real chores become linked stages, followed by free-text stages" do
    a = chore("Wipe sides")
    b = chore("Mop floor")
    battle = stacked([ a, b ], extra: [ "Bins out" ])
    assert_equal [ "Wipe sides", "Mop floor", "Bins out" ], battle.stages.map(&:title)
    assert_equal [ a.id, b.id, nil ], battle.stages.map(&:task_id)
    assert_equal 100, battle.stages.sum(&:damage)
  end

  test "someone else's chores and finished chores cannot be stacked" do
    theirs = users(:two).tasks.create!(title: "Their chore")
    done = chore("Done")
    done.complete!(today: @user.today)
    battle = BossBattle.build_for(@user, title: "x", monster_key: "toy_swarm", stage_titles: %w[a b c], task_ids: [ theirs.id, done.id ])
    assert_equal 3, battle.stages.size
    assert battle.stages.none?(&:linked?)
  end

  test "completing a stacked chore clears its stage and pays stage xp" do
    tasks = %w[A B C].map { |t| chore(t) }
    battle = stacked(tasks)
    completion = tasks.first.complete!(today: @user.today)
    assert_equal 1, completion.boss_results.size
    assert battle.reload.stages.first.done?
    assert_equal 67, battle.health_remaining
    assert_equal 1, RewardTransaction.where(kind: "boss_stage").count
  end

  test "completing every stacked chore defeats the boss with the stacked bonus" do
    tasks = %w[A B C].map { |t| chore(t) }
    battle = stacked(tasks)
    results = tasks.map { |t| t.complete!(today: @user.today).boss_results.first.last }
    assert results.last.defeated
    assert battle.reload.defeated?
    assert_equal 150 + 15 * 3, results.last.defeat_award.xp
  end

  test "a recurring chore only clears its stage once" do
    daily = @user.tasks.create!(title: "Wipe sides", recurrence_kind: "completion", recurrence_interval_days: 1)
    battle = stacked([ daily ], extra: %w[x y])
    daily.complete!(today: @user.today)
    assert_equal 1, battle.reload.stages.count(&:done?)
    daily.update!(next_due_on: nil)
    assert_empty daily.complete!(today: @user.today).boss_results
    assert_equal 1, RewardTransaction.where(kind: "boss_stage").count
  end

  test "an unrelated chore changes nothing" do
    stacked(%w[A B C].map { |t| chore(t) })
    assert_empty chore("Other").complete!(today: @user.today).boss_results
  end

  test "defeat reward grows with the number of stages" do
    assert_operator Game::Economy.boss_defeat(stages: 8)[:xp], :>, Game::Economy.boss_defeat(stages: 3)[:xp]
  end
end

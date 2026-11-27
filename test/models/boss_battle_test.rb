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
    # four stages (10 each) plus 150 defeat xp
    assert_equal 40 + 150, xp
    assert_equal 60, PlayerProgress.find_by!(user: @user).coins
    assert_equal 1, RewardTransaction.where(kind: "boss_defeat").count
  end

  test "a defeated boss cannot be fought again" do
    b = battle
    b.stages.each { |s| b.complete_stage!(s) }
    assert_nil b.complete_stage!(b.stages.first)
    assert_equal 190, xp
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
end

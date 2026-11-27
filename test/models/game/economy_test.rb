require "test_helper"

class Game::EconomyTest < ActiveSupport::TestCase
  test "xp and coins come from config by effort" do
    assert_equal 15, Game::Economy.xp_for("tiny")
    assert_equal 150, Game::Economy.xp_for("boss")
    assert_equal 8, Game::Economy.coins_for("tiny")
    assert_equal 75, Game::Economy.coins_for("boss")
  end

  test "level thresholds are cumulative" do
    assert_equal 0, Game::Economy.xp_to_reach(1)
    assert_equal 100, Game::Economy.xp_to_reach(2)
    assert_equal 300, Game::Economy.xp_to_reach(3)
    assert_equal 600, Game::Economy.xp_to_reach(4)
  end

  test "level is derived from total xp" do
    assert_equal 1, Game::Economy.level_for(0)
    assert_equal 1, Game::Economy.level_for(99)
    assert_equal 2, Game::Economy.level_for(100)
    assert_equal 2, Game::Economy.level_for(299)
    assert_equal 3, Game::Economy.level_for(300)
  end
end

require "test_helper"

class Game::AwardOneOffTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  def award(reference = "welcome", kind: "welcome", xp: 20)
    Game::AwardOneOff.call(user: @user, kind: kind, reference: reference, xp: xp)
  end

  test "awards once per reference" do
    assert award.awarded
    assert_not award.awarded
    assert_equal 20, PlayerProgress.find_by!(user: @user).xp
  end

  test "different references each pay once" do
    award("1:2026-05-06", kind: "start", xp: 3)
    award("2:2026-05-06", kind: "start", xp: 3)
    award("1:2026-05-06", kind: "start", xp: 3)
    assert_equal 6, PlayerProgress.find_by!(user: @user).xp
  end

  test "the database refuses a duplicate row" do
    award
    assert_raises(ActiveRecord::RecordNotUnique) do
      RewardTransaction.create!(user: @user, kind: "welcome", reference: "welcome", xp_delta: 1)
    end
  end

  test "reports a level up" do
    @user.progress.update!(xp: 95)
    assert award.leveled_up?
  end
end

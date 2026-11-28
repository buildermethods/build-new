require "test_helper"

class ChallengesTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.tasks.destroy_all
    @today = Date.new(2026, 5, 6) # a Wednesday, ISO week 19
  end

  def finish(task, on: @today)
    task.update_columns(next_due_on: nil, deferred_until: nil, completed_at: nil)
    task.complete!(today: on, at: @user.zone.local(on.year, on.month, on.day, 9))
  end

  def quick(title = "Quick", **attrs)
    @user.tasks.create!({ title: title, duration_minutes: 3, effort: "tiny", room: "kitchen", recurrence_kind: "completion", recurrence_interval_days: 1 }.merge(attrs))
  end

  def current(today: @today)
    Challenges::Current.new(@user, today: today).call
  end

  test "there is always one daily and one weekly challenge" do
    assert_equal %w[daily weekly], current.map { |c| c[:period] }
  end

  test "selection is deterministic: the same day always gives the same challenge" do
    assert_equal current.map { |c| c[:key] }, current.map { |c| c[:key] }
  end

  test "the daily challenge changes day to day and the weekly week to week" do
    keys = (0..10).map { |i| current(today: @today + i).first[:key] }
    assert_operator keys.map { |k| k.split(":").last }.uniq.size, :>, 1
    weekly = (0..40).step(7).map { |i| current(today: @today + i).last[:key].split(":").last }
    assert_operator weekly.uniq.size, :>, 1
  end

  test "keys carry the period so a past challenge can't be claimed today" do
    assert_match(/\Adaily:2026-05-06:/, current.first[:key])
    assert_match(/\Aweekly:2026-W19:/, current.last[:key])
  end

  test "progress counts only work in the current period" do
    daily = current.first
    config = Game::Catalog.challenges["daily"].find { |c| c["key"] == daily[:key].split(":").last }
    task = quick
    finish(task, on: @today - 1)
    assert_equal 0, current.first[:current] if %w[completions quick room:kitchen].include?(config["metric"])
  end

  test "weekly progress counts the whole Monday to Sunday week" do
    task = quick
    finish(task, on: Date.new(2026, 5, 4))
    finish(task, on: Date.new(2026, 5, 5))
    metric = Challenges::Current.new(@user, today: @today)
    weekly = metric.call.last
    config = Game::Catalog.challenges["weekly"].find { |c| c["key"] == weekly[:key].split(":").last }
    expected = { "completions" => 2, "room:kitchen" => 2, "active_days" => 2, "boss_stages" => 0 }[config["metric"]]
    assert_equal [ expected, config["target"] ].min, weekly[:current]
  end

  test "progress never exceeds the target" do
    task = quick
    12.times { |i| finish(task, on: @today - (i % 3)) }
    assert current.all? { |c| c[:current] <= c[:target] }
  end

  test "every configured challenge has a known metric" do
    %w[daily weekly].each do |period|
      Game::Catalog.challenges[period].each do |c|
        assert_match(/\A(completions|quick|active_days|starts|boss_stages|room:\w+|category:\w+)\z/, c["metric"], c["key"])
        assert c["target"].positive? && c["xp"].positive?, c["key"]
      end
    end
  end

  # --- claiming ----------------------------------------------------------------

  def complete_daily!
    daily = current.first
    config = Game::Catalog.challenges["daily"].find { |c| c["key"] == daily[:key].split(":").last }
    case config["metric"]
    when "starts"
      Game::AwardOneOff.call(user: @user, kind: "start", reference: "x:#{@today}", xp: 3)
    else
      room = config["metric"].start_with?("room:") ? config["metric"].split(":").last : "kitchen"
      config["target"].times { |i| finish(quick("Q#{i}", room: room)) }
    end
  end

  test "cannot claim before the target is reached" do
    result = Challenges::Claim.call(user: @user, period: "daily")
    assert_not result.ok
    assert_equal :incomplete, result.error
  end

  test "claiming pays once" do
    travel_to @user.zone.local(2026, 5, 6, 12) do
      complete_daily!
      before = PlayerProgress.find_by!(user: @user).xp
      first = Challenges::Claim.call(user: @user, period: "daily")
      assert first.ok
      assert_equal before + first.award.xp, PlayerProgress.find_by!(user: @user).xp
      second = Challenges::Claim.call(user: @user, period: "daily")
      assert_not second.ok
      assert_equal :already_claimed, second.error
      assert_equal 1, RewardTransaction.where(kind: "challenge").count
    end
  end

  test "an unknown period is rejected" do
    assert_equal :unknown, Challenges::Claim.call(user: @user, period: "monthly").error
  end

  test "the database refuses a duplicate claim row" do
    travel_to @user.zone.local(2026, 5, 6, 12) do
      complete_daily!
      key = Challenges::Claim.call(user: @user, period: "daily").challenge[:key]
      assert_raises(ActiveRecord::RecordNotUnique) do
        RewardTransaction.create!(user: @user, kind: "challenge", reference: key, xp_delta: 1)
      end
    end
  end
end

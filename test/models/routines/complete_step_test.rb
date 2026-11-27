require "test_helper"

class Routines::CompleteStepTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @today = Date.new(2026, 5, 6)
    @routine = @user.routines.create!(name: "Morning")
    @routine.replace_steps!([ { title: "Brush teeth" }, { title: "Wipe", task_id: tasks(:wipe_counters).id } ])
    @plain, @linked = @routine.steps.reload.to_a
  end

  def tick(step)
    Routines::CompleteStep.call(step: step, today: @today)
  end

  test "ticking a plain step records it and awards nothing" do
    result = tick(@plain)
    assert_not result.routine_done
    assert_nil result.bonus
    assert_equal 0, @user.reload.progress.xp
  end

  test "ticking a linked step completes its task and awards task xp once" do
    result = tick(@linked)
    assert result.task_completion.reward.awarded
    assert_equal 15, @user.reload.progress.xp
  end

  test "ticking the same step twice does nothing extra" do
    tick(@linked)
    again = tick(@linked)
    assert_nil again.task_completion
    assert_equal 15, @user.reload.progress.xp
    assert_equal 1, Completion.where(task: tasks(:wipe_counters)).count
  end

  test "finishing every step awards the routine bonus exactly once" do
    tick(@plain)
    result = tick(@linked)
    assert result.routine_done
    assert result.bonus.awarded
    # task xp 15 + bonus 20
    assert_equal 35, @user.reload.progress.xp
    assert_equal 1, RewardTransaction.where(kind: "routine_bonus").count
  end

  test "untick then retick does not pay the bonus twice" do
    tick(@plain)
    tick(@linked)
    Routines::CompleteStep.undo(step: @plain, today: @today)
    result = tick(@plain)
    assert_nil result.bonus
    assert_equal 1, RewardTransaction.where(kind: "routine_bonus").count
    assert_equal 35, @user.reload.progress.xp
  end

  test "the bonus is available again the next day" do
    tick(@plain)
    tick(@linked)
    @today += 1
    tick(@plain)
    result = tick(@linked)
    assert result.bonus&.awarded
    assert_equal 2, RewardTransaction.where(kind: "routine_bonus").count
  end

  test "the database refuses a duplicate bonus row" do
    tick(@plain)
    tick(@linked)
    assert_raises(ActiveRecord::RecordNotUnique) do
      RewardTransaction.create!(user: @user, kind: "routine_bonus", reference: "#{@routine.id}:#{@today.iso8601}", xp_delta: 1)
    end
  end
end

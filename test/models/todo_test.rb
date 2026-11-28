require "test_helper"

class TodoTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  def todo(title = "Call the plumber")
    @user.todos.create!(title: title)
  end

  test "requires a title, tidies spaces and limits length" do
    assert_not @user.todos.build(title: "  ").valid?
    assert_not @user.todos.build(title: "x" * 201).valid?
    assert_equal "Call the plumber", todo("  Call   the plumber ").title
  end

  test "ticking marks it done and awards a tiny xp once" do
    t = todo
    result = t.complete!
    assert t.reload.done?
    assert_equal 2, result.xp
    assert_equal 2, PlayerProgress.find_by!(user: @user).xp
  end

  test "ticking twice does nothing the second time" do
    t = todo
    t.complete!
    assert_nil t.complete!
    assert_equal 2, PlayerProgress.find_by!(user: @user).xp
  end

  test "unticking then re-ticking never pays again" do
    t = todo
    t.complete!
    t.uncomplete!
    assert_not t.reload.done?
    assert_nil t.complete!
    assert_equal 2, PlayerProgress.find_by!(user: @user).xp
    assert_equal 1, RewardTransaction.where(kind: "todo").count
  end

  test "rewards stop after the daily cap but to-dos still tick" do
    cap = Game::Economy.todo_daily_cap
    (cap + 2).times { |i| todo("Item #{i}").complete! }
    assert_equal cap, RewardTransaction.where(kind: "todo").count
    assert_equal cap + 2, @user.todos.done.count
  end

  test "the database refuses a duplicate reward row" do
    t = todo
    t.complete!
    assert_raises(ActiveRecord::RecordNotUnique) do
      RewardTransaction.create!(user: @user, kind: "todo", reference: "todo:#{t.id}", xp_delta: 1)
    end
  end

  test "is destroyed with its user" do
    todo
    assert_difference -> { Todo.count }, -@user.todos.count do
      @user.destroy
    end
  end
end

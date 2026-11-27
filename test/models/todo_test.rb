require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "is incomplete by default" do
    assert_not users(:one).todos.create!(description: "New").completed
  end

  test "requires a description" do
    todo = users(:one).todos.build(description: " ")
    assert_not todo.valid?
    assert todo.errors[:description].any?
  end

  test "limits description length" do
    assert_not users(:one).todos.build(description: "a" * 501).valid?
  end

  test "is destroyed with its user" do
    assert_difference -> { Todo.count }, -users(:one).todos.count do
      users(:one).destroy
    end
  end
end

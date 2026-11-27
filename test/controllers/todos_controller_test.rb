require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @todo = todos(:buy_milk)
  end

  test "requires authentication" do
    post todos_path, params: { description: "x" }
    assert_redirected_to login_path
  end

  test "creates a todo for the current user" do
    log_in_as(@user)
    assert_difference -> { @user.todos.count }, 1 do
      post todos_path, params: { description: "Walk dog" }
    end
    assert_redirected_to root_path
  end

  test "rejects a blank description" do
    log_in_as(@user)
    assert_no_difference -> { Todo.count } do
      post todos_path, params: { description: "" }
    end
    assert_response :redirect
  end

  test "edits the description" do
    log_in_as(@user)
    patch todo_path(@todo), params: { description: "Buy oat milk" }
    assert_redirected_to root_path
    assert_equal "Buy oat milk", @todo.reload.description
  end

  test "rejects a blank description on edit" do
    log_in_as(@user)
    patch todo_path(@todo), params: { description: "" }
    assert_response :redirect
    assert_equal "Buy milk", @todo.reload.description
  end

  test "completes and un-completes" do
    log_in_as(@user)
    patch todo_path(@todo), params: { completed: true }
    assert @todo.reload.completed
    patch todo_path(@todo), params: { completed: false }
    assert_not @todo.reload.completed
  end

  test "deletes a todo" do
    log_in_as(@user)
    assert_difference -> { Todo.count }, -1 do
      delete todo_path(@todo)
    end
    assert_redirected_to root_path
  end

  test "cannot modify another user's todo" do
    log_in_as(@user)
    other = todos(:other_users_todo)
    patch todo_path(other), params: { description: "hacked" }
    assert_response :not_found
    assert_no_difference -> { Todo.count } do
      delete todo_path(other)
    end
    assert_equal "Not yours", other.reload.description
  end
end

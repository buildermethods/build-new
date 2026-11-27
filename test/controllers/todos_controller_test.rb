require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @todo = @user.todos.create!(title: "Buy stamps")
    @theirs = users(:two).todos.create!(title: "Not yours")
  end

  def xp
    PlayerProgress.find_by!(user: @user).xp
  end

  test "requires authentication" do
    get todos_path
    assert_redirected_to login_path
    post todos_path, params: { title: "x" }
    assert_redirected_to login_path
  end

  test "lists only my to-dos" do
    log_in_as(@user)
    get todos_path
    assert_response :success
    assert_includes response.body, "Buy stamps"
    assert_not_includes response.body, "Not yours"
  end

  test "creates a to-do" do
    log_in_as(@user)
    assert_difference -> { @user.todos.count }, 1 do
      post todos_path, params: { title: "Water the fern" }
    end
    assert_response :redirect
  end

  test "rejects a blank to-do" do
    log_in_as(@user)
    assert_no_difference -> { Todo.count } do
      post todos_path, params: { title: "  " }
    end
    assert_response :redirect
  end

  test "edits a to-do" do
    log_in_as(@user)
    patch todo_path(@todo), params: { title: "Buy first-class stamps" }
    assert_equal "Buy first-class stamps", @todo.reload.title
  end

  test "ticks and unticks, awarding xp only once" do
    log_in_as(@user)
    post complete_todo_path(@todo)
    assert @todo.reload.done?
    assert_equal 2, xp
    post uncomplete_todo_path(@todo)
    assert_not @todo.reload.done?
    post complete_todo_path(@todo)
    assert_equal 2, xp
  end

  test "deletes a to-do" do
    log_in_as(@user)
    assert_difference -> { Todo.count }, -1 do
      delete todo_path(@todo)
    end
  end

  test "cannot touch another user's to-do" do
    log_in_as(@user)
    patch todo_path(@theirs), params: { title: "hacked" }
    assert_response :not_found
    post complete_todo_path(@theirs)
    assert_response :not_found
    delete todo_path(@theirs)
    assert_response :not_found
    assert_equal "Not yours", @theirs.reload.title
  end

  test "Today shows a few open to-dos" do
    log_in_as(@user)
    get root_path
    assert_includes response.body, "Buy stamps"
    assert_not_includes response.body, "Not yours"
    assert_includes response.body, "&quot;todo_open_count&quot;:1"
  end
end

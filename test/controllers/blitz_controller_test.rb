require "test_helper"

class BlitzControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.tasks.destroy_all
  end

  def chore(title, minutes)
    @user.tasks.create!(title: title, duration_minutes: minutes)
  end

  test "requires authentication" do
    get blitz_path
    assert_redirected_to login_path
  end

  test "lines up the shortest chores that fit the time" do
    log_in_as(@user)
    chore("Quick", 3)
    chore("Medium", 5)
    chore("Long", 25)
    get blitz_path(minutes: 10)
    assert_response :success
    assert_includes response.body, "Quick"
    assert_includes response.body, "Medium"
    assert_not_includes response.body, "&quot;title&quot;:&quot;Long&quot;"
  end

  test "an odd length falls back to ten minutes" do
    log_in_as(@user)
    get blitz_path(minutes: 999)
    assert_includes response.body, "&quot;minutes&quot;:10"
  end

  test "completing from the blitz rewards once and says so without the victory dialog" do
    log_in_as(@user)
    task = chore("Wipe", 3)
    assert_difference -> { @user.progress.reload.xp }, task.xp do
      post blitz_complete_path(task, minutes: 10)
    end
    assert_redirected_to blitz_path(minutes: 10)
    assert_match "Done!", flash[:notice]
    assert_nil flash[:victory]
  end

  test "cannot complete someone else's chore" do
    log_in_as(@user)
    theirs = users(:two).tasks.create!(title: "Theirs")
    post blitz_complete_path(theirs)
    assert_response :not_found
  end
end

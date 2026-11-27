require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @user.update!(onboarded_at: nil)
    @user.tasks.destroy_all
  end

  def draft
    Onboarding::Draft.new(@user.reload)
  end

  # --- one-time gate -------------------------------------------------------

  test "new users are sent to the welcome page from the root" do
    log_in_as(@user)
    get root_path
    assert_redirected_to welcome_path
  end

  test "onboarded users never see the setup screens again" do
    log_in_as(users(:one))
    %w[/welcome /welcome/rooms /welcome/chores /welcome/frequency /welcome/finish].each do |path|
      get path
      assert_redirected_to root_path, "#{path} should redirect an onboarded user"
    end
    post "/welcome/rooms", params: { rooms: { kitchen: 1 } }
    assert_redirected_to root_path
  end

  test "add-chores screens are only for onboarded users" do
    log_in_as(@user)
    get "/add-chores/rooms"
    assert_redirected_to welcome_path
  end

  test "logged-out visitors are sent to log in" do
    get "/welcome"
    assert_redirected_to login_path
  end

  # --- the wizard ----------------------------------------------------------

  test "intro, rooms, chores, frequency and finish all render in order" do
    log_in_as(@user)
    get welcome_path
    assert_response :success
    get "/welcome/rooms"
    assert_response :success
    assert_includes response.body, "&quot;component&quot;:&quot;onboarding/Rooms&quot;"

    post "/welcome/rooms", params: { rooms: { kitchen: 1, bedroom: 2 } }
    assert_redirected_to "/welcome/chores"
    get "/welcome/chores"
    assert_response :success
    assert_includes response.body, "Wipe the kitchen sides"

    post "/welcome/chores", params: { chores: %w[kitchen.wipe_sides kitchen.oven bedroom.bed] }
    assert_redirected_to "/welcome/frequency"
    get "/welcome/frequency"
    assert_response :success
    assert_includes response.body, "Clean the oven"

    post "/welcome/frequency", params: { frequencies: { "kitchen.oven" => "quarterly" } }
    assert_redirected_to "/welcome/finish"
    get "/welcome/finish"
    assert_response :success
  end

  test "the whole setup creates the chosen chores and lands on a first quest" do
    log_in_as(@user)
    post "/welcome/rooms", params: { rooms: { kitchen: 1, bedroom: 2 } }
    post "/welcome/chores", params: { chores: %w[kitchen.wipe_sides kitchen.oven bedroom.bed] }
    post "/welcome/frequency", params: { frequencies: { "kitchen.oven" => "quarterly" } }

    assert_difference -> { @user.tasks.count }, 4 do # sides, oven, bed x2
      post "/welcome/finish", params: { display_name: "Gemma", anchor: "after dinner", treat: "A podcast" }
    end
    assert_match(/just=1/, response.location)
    assert_equal 90, @user.tasks.find_by!(source_key: "kitchen:1:oven").recurrence_interval_days
    assert @user.reload.onboarded?
    follow_redirect!
    assert_includes response.body, "Gemma"
  end

  test "choices survive a refresh because they are saved server-side" do
    log_in_as(@user)
    post "/welcome/rooms", params: { rooms: { kitchen: 1 } }
    get "/welcome/rooms"
    assert_match(/&quot;counts&quot;:\{[^}]*&quot;kitchen&quot;:1/, response.body)
  end

  test "later steps redirect back until earlier ones are done" do
    log_in_as(@user)
    get "/welcome/chores"
    assert_redirected_to "/welcome/rooms"
    get "/welcome/frequency"
    assert_redirected_to "/welcome/rooms"
    post "/welcome/rooms", params: { rooms: { kitchen: 1 } }
    get "/welcome/frequency"
    assert_redirected_to "/welcome/chores"
    get "/welcome/finish"
    assert_redirected_to "/welcome/chores"
  end

  test "picking no rooms or no chores is rejected" do
    log_in_as(@user)
    post "/welcome/rooms", params: { rooms: {} }
    assert_response :redirect
    assert_not draft.selected_rooms?

    post "/welcome/rooms", params: { rooms: { kitchen: 1 } }
    post "/welcome/chores", params: { chores: [] }
    assert_response :redirect
    assert_empty draft.chores
  end

  test "unknown rooms, chores and frequencies are ignored" do
    log_in_as(@user)
    post "/welcome/rooms", params: { rooms: { kitchen: 1, attic: 3 } }
    post "/welcome/chores", params: { chores: %w[kitchen.wipe_sides nope.nothing kitchen.fake] }
    post "/welcome/frequency", params: { frequencies: { "kitchen.wipe_sides" => "hourly" } }
    assert_equal [ "kitchen.wipe_sides" ], draft.chores
    assert_not draft.rooms.key?("attic")
    assert_empty draft.frequencies
  end

  test "skipping marks the user onboarded without creating tasks" do
    log_in_as(@user)
    post skip_welcome_path
    assert @user.reload.onboarded?
    assert_equal 0, @user.tasks.count
    get root_path
    assert_response :success
  end

  # --- adding more chores later -------------------------------------------

  test "an onboarded user can add suggested chores without duplicates" do
    log_in_as(users(:one))
    user = users(:one)
    user.tasks.destroy_all

    2.times do
      post "/add-chores/rooms", params: { rooms: { kitchen: 1 } }
      post "/add-chores/chores", params: { chores: %w[kitchen.oven kitchen.fridge] }
      post "/add-chores/frequency", params: {}
      assert_redirected_to quests_path
    end
    assert_equal 2, user.tasks.count
  end

  test "chores already added are marked on the picker" do
    user = users(:one)
    user.tasks.destroy_all
    log_in_as(user)
    post "/add-chores/rooms", params: { rooms: { kitchen: 1 } }
    post "/add-chores/chores", params: { chores: %w[kitchen.oven] }
    post "/add-chores/frequency", params: {}
    post "/add-chores/rooms", params: { rooms: { kitchen: 1 } }
    get "/add-chores/chores"
    assert_includes response.body, "&quot;key&quot;:&quot;kitchen.oven&quot;"
    assert_match(/&quot;added&quot;:true/, response.body)
  end
end

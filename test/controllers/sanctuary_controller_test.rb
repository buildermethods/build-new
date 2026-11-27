require "test_helper"

class SanctuaryControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.progress.update!(coins: 100)
  end

  def coins
    PlayerProgress.find_by!(user: @user).coins
  end

  test "requires authentication" do
    post purchase_decoration_path("fern_pot")
    assert_redirected_to login_path
  end

  test "shows the shop with every decoration" do
    log_in_as(@user)
    get sanctuary_path
    assert_response :success
    assert_includes response.body, "Fern in a Pot"
    assert_includes response.body, "Starry Night Rug"
  end

  test "buy then equip" do
    log_in_as(@user)
    post purchase_decoration_path("fern_pot")
    assert_redirected_to sanctuary_path
    assert_equal 80, coins

    post equip_decoration_path("fern_pot")
    assert_redirected_to sanctuary_path
    assert_equal "fern_pot", SanctuaryPlacement.find_by!(user: @user, slot: "plant").decoration_key
  end

  test "cannot buy without enough coins" do
    log_in_as(@user)
    post purchase_decoration_path("starry_rug")
    assert_redirected_to sanctuary_path
    assert_match(/Not enough coins/, flash[:alert])
    assert_equal 100, coins
  end

  test "double purchase charges once" do
    log_in_as(@user)
    2.times { post purchase_decoration_path("fern_pot") }
    assert_equal 80, coins
  end

  test "cannot equip an unowned decoration" do
    log_in_as(@user)
    post equip_decoration_path("fern_pot")
    assert_match(/can't go there/, flash[:alert])
    assert_empty SanctuaryPlacement.where(user: @user)
  end

  test "unequip empties the slot" do
    log_in_as(@user)
    post purchase_decoration_path("fern_pot")
    post equip_decoration_path("fern_pot")
    post unequip_decoration_path("plant")
    assert_empty SanctuaryPlacement.where(user: @user)
  end

  test "equipped items appear on the dashboard with the next goal" do
    log_in_as(@user)
    post purchase_decoration_path("fern_pot")
    post equip_decoration_path("fern_pot")
    get root_path
    assert_includes response.body, "&quot;placements&quot;:{&quot;living_room&quot;:{&quot;plant&quot;:&quot;fern_pot&quot;}}"
    assert_includes response.body, "&quot;teaser&quot;"
  end
end

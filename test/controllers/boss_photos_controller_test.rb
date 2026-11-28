require "test_helper"

class BossPhotosControllerTest < ActionDispatch::IntegrationTest
  PNG = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/q842iQAAAABJRU5ErkJggg==")

  setup do
    @user = users(:one)
    @battle = BossBattle.build_for(@user, title: "Tidy", monster_key: "toy_swarm", stage_titles: %w[a b c]).tap(&:save!)
  end

  def upload(content: PNG, type: "image/png", name: "pic.png")
    file = Tempfile.new([ "pic", File.extname(name) ], binmode: true)
    file.write(content)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, type, true, original_filename: name)
  end

  test "requires authentication" do
    get boss_battle_photo_path(@battle, "before")
    assert_redirected_to login_path
  end

  test "the owner can add, view and remove a before photo" do
    log_in_as(@user)
    post boss_battle_photos_path(@battle, slot: "before"), params: { photo: upload }
    assert_redirected_to boss_battle_path(@battle)
    assert @battle.reload.before_photo.attached?

    get boss_battle_photo_path(@battle, "before")
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_includes response.headers["Cache-Control"], "private"

    delete boss_battle_photo_path(@battle, "before")
    assert_not @battle.reload.before_photo.attached?
  end

  test "other people cannot see or change my photos" do
    log_in_as(@user)
    post boss_battle_photos_path(@battle, slot: "after"), params: { photo: upload }
    log_in_as(users(:two))
    get boss_battle_photo_path(@battle, "after")
    assert_response :not_found
    post boss_battle_photos_path(@battle, slot: "after"), params: { photo: upload }
    assert_response :not_found
  end

  test "only images are accepted" do
    log_in_as(@user)
    post boss_battle_photos_path(@battle, slot: "before"), params: { photo: upload(content: "<script>", type: "text/html", name: "x.html") }
    assert_redirected_to boss_battle_path(@battle)
    assert_match "JPG, PNG or WebP", flash[:alert]
    assert_not @battle.reload.before_photo.attached?
  end

  test "a file that lies about being an image is rejected by its real contents" do
    log_in_as(@user)
    post boss_battle_photos_path(@battle, slot: "before"), params: { photo: upload(content: "<html><script>alert(1)</script></html>", type: "image/png", name: "x.png") }
    assert_match "JPG, PNG or WebP", flash[:alert]
    assert_not @battle.reload.before_photo.attached?
  end

  test "an unknown slot is a 404" do
    log_in_as(@user)
    get boss_battle_photo_path(@battle, "side")
    assert_response :not_found
  end

  test "the battle page links the photo through the private route" do
    log_in_as(@user)
    post boss_battle_photos_path(@battle, slot: "before"), params: { photo: upload }
    get boss_battle_path(@battle)
    assert_includes response.body, "/battles/#{@battle.id}/photos/before?v="
  end
end

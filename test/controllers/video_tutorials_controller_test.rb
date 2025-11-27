require "test_helper"

class VideoTutorialsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @user = users(:one)
    @admin = users(:admin)
    @video_tutorial = video_tutorials(:one)
    AppSetting.create!(registration_enabled: true) unless AppSetting.exists?
  end

  test "should get index" do
    get api_v1_video_tutorials_path, as: :json
    assert_response :success
  end

  test "should show video_tutorial" do
    get api_v1_video_tutorial_path(@video_tutorial), as: :json
    assert_response :success
  end

  test "should create video_tutorial" do
    log_in_as(@admin)
    post api_v1_video_tutorials_path, params: {
      title: "video tutorial",
      description: "video tutorial",
      thumbnail: fixture_file_upload("image1.jpg", "image/jpeg"),
      video: fixture_file_upload("sample.mp4", "video/mp4")

    }, headers: @auth_headers
    assert_response :success
  end

  test "should update video_tutorial" do
    log_in_as(@admin)
    patch api_v1_video_tutorial_path(@video_tutorial), params: {
      title: "NewTitle"
    }, headers: @auth_headers
    assert_equal "NewTitle", @video_tutorial.title
  end

  test "should destroy video_tutorial" do
    log_in_as(@admin)
    delete api_v1_video_tutorial_path(@video_tutorial), headers: @auth_headers
    assert_response :success
  end
end

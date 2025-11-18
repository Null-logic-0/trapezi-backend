require "test_helper"

class BlogsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @blog = blogs(:one)
    @user = users(:admin)
  end

  test "should get index" do
    get api_v1_blogs_path, as: :json
    assert_response :success
  end

  test "should show blog" do
    get api_v1_blog_path(@blog), as: :json
    assert_response :success
  end

  test "should create blog" do
    log_in_as(@user)
    post api_v1_blogs_path,
         params: {
           title: "New Blog",
           content: "New Blog description",
           image: fixture_file_upload("image1.jpg", "image/jpg")
         }, headers: @auth_headers

    assert_response :created
  end

  test "should update blog" do
    log_in_as(@user)

    patch api_v1_blog_path(@blog), params: {
      title: "NewTitle"
    }, headers: @auth_headers

    assert_equal "NewTitle", @blog.title
  end

  test "should destroy blog" do
    log_in_as(@user)

    delete api_v1_blog_path(@blog), headers: @auth_headers
    assert_response :success
  end
end

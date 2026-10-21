require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "updating a user's name logs that user in" do
    user = users(:one)

    patch user_path(user), params: { user: { name: "Updated Name" } }

    assert_redirected_to user_path(user)
    assert_equal user.id, session[:user_id]
  end

  test "saving a taken name on show shows an error" do
    user = User.create!(qr_code: "unnamed")

    patch user_path(user), params: { user: { name: "fixture one" } }

    assert_response :unprocessable_entity
    assert_select "p", "Name has already been taken"
    assert_select "form.save-name-form"
    assert_nil user.reload.name
  end

  test "should get index" do
    get users_index_url
    assert_response :success
  end

  test "should get show" do
    get users_show_url
    assert_response :success
  end

  test "should get new" do
    get users_new_url
    assert_response :success
  end

  test "should get create" do
    get users_create_url
    assert_response :success
  end

  test "should get edit" do
    get users_edit_url
    assert_response :success
  end

  test "should get update" do
    get users_update_url
    assert_response :success
  end

  test "should get destroy" do
    get users_destroy_url
    assert_response :success
  end
end

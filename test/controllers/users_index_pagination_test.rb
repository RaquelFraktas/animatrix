require "test_helper"

class UsersIndexPaginationTest < ActionDispatch::IntegrationTest
  test "paginates players" do
    per_page = UsersController::USERS_PER_PAGE
    (per_page + 3 - User.count).times { |i| User.create!(name: "Player #{i}", qr_code: "page-#{i}") }

    get users_path
    assert_response :success
    assert_select "ul li", per_page
    assert_select ".users-pagination a", text: "2"

    get users_path(page: 2)
    assert_select "ul li", 3
  end

  test "hides pagination when there is one page" do
    get users_path
    assert_response :success
    assert_select ".users-pagination", false
  end
end

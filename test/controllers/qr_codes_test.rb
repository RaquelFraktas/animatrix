require "test_helper"

class QrCodesTest < ActionDispatch::IntegrationTest
  test "shows every player's QR code across pages" do
    per_page = UsersController::QR_CODES_PER_PAGE
    (per_page + 5 - User.count).times { |i| User.create!(qr_code: "print-#{i}") }

    get qr_codes_path
    assert_response :success
    assert_select ".qr-sheet-code svg", per_page
    assert_select ".qr-sheet-pagination a", text: "2"

    get qr_codes_path(page: 2)
    assert_select ".qr-sheet-code svg", 5
  end

  test "out of range pages show the last page" do
    get qr_codes_path(page: 99)
    assert_response :success
    assert_select ".qr-sheet-code svg", User.count
  end
end

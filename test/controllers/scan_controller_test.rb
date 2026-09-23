require "test_helper"

class ScanControllerTest < ActionDispatch::IntegrationTest
  test "saving an unnamed player redirects to the users index" do
    user = User.create!(qr_code: "scan-name-test")

    post scan_path, params: {
      qr_code: user.qr_code,
      target_name: "Grace"
    }

    assert_redirected_to users_path
    assert_equal "Grace", user.reload.name
  end
end

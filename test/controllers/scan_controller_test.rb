require "test_helper"

class ScanControllerTest < ActionDispatch::IntegrationTest
  test "saving an unnamed player shows the new name in the scan result" do
    user = User.create!(qr_code: "scan-name-test")

    post scan_path,
         params: { qr_code: user.qr_code, target_name: "Grace" },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes response.media_type, "text/vnd.turbo-stream.html"
    assert_includes response.body, 'id="scan_result"'
    assert_includes response.body, "<h2>Grace</h2>"
    assert_equal "Grace", user.reload.name
  end

  test "successful kill replaces the scan result with the dead state" do
    killer = User.create!(qr_code: "scan-killer-test")
    victim = User.create!(name: "Victim", qr_code: "scan-victim-test")

    post scan_path, params: { qr_code: killer.qr_code, target_name: "Killer" }
    post scan_path,
         params: { qr_code: victim.qr_code },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes response.media_type, "text/vnd.turbo-stream.html"
    assert_includes response.body, "Victim is dead."
    assert_includes response.body, 'id="scan_result"'
    assert_includes response.body, 'data-controller="scan-result"'
    assert_includes response.body, 'data-scan-result-redirect-delay-value="15000"'
    assert_includes response.body, 'data-scan-result-scoreboard-url-value="/users"'
    assert_equal "killed", victim.reload.status
  end
end

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
    assert_includes response.body, "Player name: Grace"
    assert_equal "Grace", user.reload.name
  end

  test "saving a name that is already taken shows an error" do
    User.create!(name: "Grace", qr_code: "scan-taken-test")
    user = User.create!(qr_code: "scan-duplicate-test")

    post scan_path, params: { qr_code: user.qr_code, target_name: "Grace" }

    assert_response :unprocessable_entity
    assert_includes response.body, "Name has already been taken"
    assert_includes response.body, "This QR code needs a name"
    assert_nil user.reload.name
  end

  test "scanning a dead player shows an error modal" do
    scanner = User.create!(qr_code: "scan-alive-scanner")
    dead = User.create!(name: "Dead", qr_code: "scan-dead-target", status: "killed")

    post scan_path, params: { qr_code: scanner.qr_code, target_name: "Scanner" }
    get scan_path(qr_code: dead.qr_code)

    assert_response :success
    assert_includes response.body, 'data-controller="game-play-modal"'
    assert_includes response.body, "Dead is already dead."
  end

  test "a dead player scanning someone shows an error modal" do
    scanner = User.create!(qr_code: "scan-dead-scanner")
    target = User.create!(name: "Target", qr_code: "scan-alive-target")

    post scan_path, params: { qr_code: scanner.qr_code, target_name: "Ghost" }
    scanner.update!(status: "killed")
    get scan_path(qr_code: target.qr_code)

    assert_response :success
    assert_includes response.body, "You are dead. You can&#39;t free any more minds."
    assert_not_includes response.body, "Free Target"
  end

  test "scanning a living player as a living player shows no error modal" do
    scanner = User.create!(qr_code: "scan-living-scanner")
    target = User.create!(name: "Alive", qr_code: "scan-living-target")

    post scan_path, params: { qr_code: scanner.qr_code, target_name: "Living" }
    get scan_path(qr_code: target.qr_code)

    assert_response :success
    assert_not_includes response.body, "ACCESS DENIED"
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
    assert_match(/Victim is .*dead/, response.body)
    assert_includes response.body, 'id="scan_result"'
    assert_includes response.body, 'data-controller="page-shake"'
    assert_includes response.body, 'data-page-shake-count-value="3"'
    assert_includes response.body, 'data-page-shake-redirect-delay-value="15000"'
    assert_includes response.body, 'data-page-shake-redirect-url-value="/users"'
    assert_equal "killed", victim.reload.status
  end
end

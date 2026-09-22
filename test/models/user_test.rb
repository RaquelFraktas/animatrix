require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "defaults to alive with zero kills and empty killed ids" do
    user = User.new(name: "Grace")

    assert user.valid?
    assert_equal "alive", user.status
    assert_equal 0, user.kill_count
    assert_equal [], user.killed_user_ids
  end

  test "status must be alive or killed" do
    user = User.new(name: "Grace", status: "zombie")

    assert_not user.valid?
    assert_includes user.errors[:status], "must be either 'alive' or 'killed'"
  end

  test "finds or initializes a user from a QR code" do
    existing = User.create!(name: "Grace", qr_code: "scan-123")

    found = User.find_or_initialize_by_qr_code("scan-123")
    assert_equal existing.id, found.id

    created = User.find_or_initialize_by_qr_code("scan-456")
    assert created.persisted?
    assert_equal "scan-456", created.qr_code
    assert_equal "alive", created.status
    assert_equal "Player 2", created.name
  end
end

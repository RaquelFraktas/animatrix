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
end

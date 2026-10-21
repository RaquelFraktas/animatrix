require "test_helper"

class GameTest < ActiveSupport::TestCase
  teardown { ENV.delete("GAME_LOCKS_AT") }

  test "is unlocked when no lock time is set" do
    assert_nil Game.locks_at
    assert_not Game.locked?
  end

  test "is unlocked before the lock time and locked after it" do
    ENV["GAME_LOCKS_AT"] = 1.hour.from_now.iso8601
    assert_not Game.locked?

    ENV["GAME_LOCKS_AT"] = 1.minute.ago.iso8601
    assert Game.locked?
  end

  test "ignores an invalid lock time" do
    ENV["GAME_LOCKS_AT"] = "not a time"
    assert_not Game.locked?
  end

  test "players cannot kill after the game locks" do
    ENV["GAME_LOCKS_AT"] = 1.minute.ago.iso8601
    victim = users(:two)

    assert_not users(:one).kill!(victim)
    assert victim.reload.alive?
    assert_equal 0, Kill.count
  end
end

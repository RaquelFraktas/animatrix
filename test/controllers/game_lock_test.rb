require "test_helper"

class GameLockTest < ActionDispatch::IntegrationTest
  teardown { ENV.delete("GAME_LOCKS_AT") }

  test "scanning after the game locks shows the sentinels error and blocks the kill" do
    ENV["GAME_LOCKS_AT"] = 1.minute.ago.iso8601
    victim = users(:two)
    post login_path, params: { id: users(:one).id }

    post scan_path, params: { qr_code: victim.qr_code }
    follow_redirect!

    assert_select "dialog p", "The sentinels have arrived. No more minds can be freed."
    assert victim.reload.alive?
  end

  test "players cannot change their status after the game locks" do
    ENV["GAME_LOCKS_AT"] = 1.minute.ago.iso8601
    user = users(:one)

    patch user_path(user), params: { user: { status: "killed" } }

    assert user.reload.alive?
  end

  test "the scoreboard shows a countdown to the lock time" do
    locks_at = 2.hours.from_now.change(usec: 0)
    ENV["GAME_LOCKS_AT"] = locks_at.iso8601

    get highscores_path

    assert_select "[data-controller=countdown][data-countdown-ends-at-value=?]", locks_at.iso8601
  end
end

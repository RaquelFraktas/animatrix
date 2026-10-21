require "test_helper"

class KillTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "killing a player tells them to get a glowstick" do
    victim = users(:two)

    stream = "#{victim.to_gid_param}:status"
    broadcast = capture_broadcasts(stream) { users(:one).kill!(victim) }.sole
    assert_includes broadcast, "GLOWSTICK NECKLACE"
    assert_includes broadcast, 'data-game-play-modal-reload-on-close-value="true"'
  end
end

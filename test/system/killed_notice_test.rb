require "application_system_test_case"

class KilledNoticeTest < ApplicationSystemTestCase
  setup do
    ActionCable.server.config.cable = { "adapter" => "async" }
    ActionCable.server.restart
  end

  teardown do
    ActionCable.server.config.cable = { "adapter" => "test" }
    ActionCable.server.restart
  end

  test "victim on their player page sees the glowstick popup when killed" do
    victim = users(:two)

    visit login_path
    select victim.name, from: "id"
    click_on "Sign in"
    assert_text "SIGNED IN AS"
    visit user_path(victim)
    assert_selector "turbo-cable-stream-source[connected]", visible: false

    users(:one).kill!(victim)

    assert_selector "dialog[open]", text: "GLOWSTICK NECKLACE"
    assert_selector "body.page-shake"
  end
end

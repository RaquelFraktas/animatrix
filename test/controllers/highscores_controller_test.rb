require "test_helper"

class HighscoresControllerTest < ActionDispatch::IntegrationTest
  test "shows the five players with the most kills" do
    users = 6.times.map do |index|
      User.create!(name: "Player #{index}", qr_code: "score-player-#{index}")
    end

    6.times do |index|
      index.times do |victim_index|
        victim = User.create!(
          name: "Victim #{index}-#{victim_index}",
          qr_code: "score-victim-#{index}-#{victim_index}"
        )
        users[index].kills_as_killer.create!(victim: victim)
      end
    end

    get highscores_path

    assert_response :success
    assert_select "ol > li", count: 5
    assert_select "ol > li:first-child", text: /Player 5.*5 kills/
    assert_select "ol > li:last-child", text: /Player 1.*1 kill/
    assert_no_match(/Player 0/, response.body)
  end
end

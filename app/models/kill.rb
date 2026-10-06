class Kill < ApplicationRecord
  belongs_to :killer, class_name: "User"
  belongs_to :victim, class_name: "User"

  after_commit :broadcast_highscores, on: %i[create update destroy]

  private

  def broadcast_highscores
    Turbo::StreamsChannel.broadcast_replace_to(
      "highscores",
      target: "entries",
      partial: "highscores/highscores",
      locals: {
        highscores: User.highscores,
        alive_player_count: User.where(status: "alive").count
      }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      "highscores",
      target: "leaderboard_stats",
      partial: "highscores/stats"
    )
  end
end

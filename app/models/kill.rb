class Kill < ApplicationRecord
  belongs_to :killer, class_name: "User"
  belongs_to :victim, class_name: "User"

  after_create_commit :broadcast_highscores

  private

  def broadcast_highscores
    Turbo::StreamsChannel.broadcast_replace_to(
      "highscores",
      target: "entries",
      partial: "highscores/highscores",
      locals: { highscores: User.highscores }
    )
  end
end

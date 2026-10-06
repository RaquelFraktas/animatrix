class HighscoresController < ApplicationController
  def index
    @highscores = User.highscores
    @alive_player_count = User.where(status: "alive").count
  end
end

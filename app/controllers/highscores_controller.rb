class HighscoresController < ApplicationController
  def index
    @highscores = User.highscores
  end
end

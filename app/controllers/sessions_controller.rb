class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(id: login_params[:id])

    unless user
      redirect_to login_path, alert: "Choose a player."
      return
    end

    reset_session
    session[:user_id] = user.id
    redirect_to users_path, notice: "Signed in."
  end

  def destroy
    reset_session
    redirect_to users_path, notice: "Signed out."
  end

  private

  def login_params
    params.permit(:id)
  end
end

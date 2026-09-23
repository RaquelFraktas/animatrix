class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.order(:id)
  end

  def show
  end

  def new
    @user = User.new(qr_code: params[:qr_code])
  end


  def create
    @user = User.new(
      user_params.merge(
        qr_code: params[:qr_code].presence || user_params[:qr_code].presence || "user-#{SecureRandom.uuid}",
        status: "alive"
      )
    )

    if @user.save
      redirect_to @user, notice: "Player created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Player updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: "Player removed."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :status, :qr_code, :kill_count, killed_user_ids: [])
  end
end

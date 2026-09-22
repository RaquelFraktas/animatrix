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
        name: user_params[:name].presence || "Player #{User.count + 1}",
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

  def scan
    code = params[:qr_code].to_s.strip

    if code.blank?
      redirect_to users_path, alert: "No QR code was provided."
      return
    end

    user = User.find_by(qr_code: code)

    if user.nil?
      redirect_to new_user_path(qr_code: code), notice: "That QR code is not attached to a player yet."
      return
    end

    if user.name.blank?
      redirect_to new_user_path(qr_code: code), notice: "This player still needs a name."
      return
    end

    if user.killed?
      redirect_to user, notice: "#{user.name} is already killed."
      return
    end

    user.update!(status: "killed")
    redirect_to user, notice: "#{user.name} was killed."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :status, :qr_code, :kill_count, killed_user_ids: [])
  end
end

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

  def scan
    # @players = User.where(status: "alive").where.not(name: nil).order(:name)
    return unless request.post?

    code = params[:qr_code].to_s.strip
    killer = User.find_by(id: params[:killer_id])

    if code.blank?
      redirect_to scan_path, alert: "No QR code was provided."
      return
    end

    unless killer&.alive?
      redirect_to scan_path, alert: "Choose your player before scanning."
      return
    end

    session[:user_id] = killer.id
    user = User.find_by(qr_code: code)

    if user.nil?
      redirect_to new_user_path(qr_code: code), notice: "That QR code is not attached to a player yet."
      return
    end

    if user.name.blank?
      name = params[:target_name].to_s.strip

      if name.present?
        unless user.update(name: name)
          @unnamed_user = user
          render :scan, status: :unprocessable_entity
          return
        end
      else
        @unnamed_user = user
        render :scan, status: :unprocessable_entity
        return
      end
    end

    if user.killed?
      redirect_to user, notice: "#{user.name} is already killed."
      return
    end

    if killer == user
      redirect_to user, alert: "You cannot kill yourself."
      return
    end

    killer.kill!(user)
    redirect_to user, notice: "#{user.name} was killed by #{killer.name}."
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

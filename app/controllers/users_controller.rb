class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.order(:id)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

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
    @user = User.new
  end

  def initialize_from_qr
    code = params[:qr_code].to_s.strip
    @user = User.find_or_initialize_by_qr_code(code)

    if @user.save
      redirect_to @user, notice: "Player initialized from QR code."
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :scan, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :status, :kill_count, :qr_code, killed_user_ids: [])
  end
end

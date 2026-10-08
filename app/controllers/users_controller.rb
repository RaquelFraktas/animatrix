class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.order(:id)
    @current_user = current_user
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
    attributes = user_params

    if @user.update(attributes)
      if attributes[:name].present?
        reset_session
        session[:user_id] = @user.id
      end

      redirect_to @user, notice: "Player updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: "Player removed."
  end

  def manual_edit
    @users = User.order(:name, :id)
    @user = @users.find_by(id: params[:user_id]) || @users.first
  end

  def manual_update
    @user = User.find(params[:user_id])
    attributes = manual_input_params
    status = attributes[:status]
    killer_id = attributes[:killer_id].presence&.to_i

    unless User::VALID_STATUSES.include?(status)
      return redirect_to manual_input_path(user_id: @user.id), alert: "Choose a valid player status."
    end

    if status == "killed"
      killer = User.find_by(id: killer_id)
      unless killer && killer != @user
        return redirect_to manual_input_path(user_id: @user.id), alert: "Choose another player as the killer."
      end
    end

    User.transaction do
      @user.status = status
      @user.save!(validate: false)

      if status == "killed"
        Kill.where(victim_id: @user.id).where.not(killer_id: killer_id).destroy_all
        Kill.find_or_create_by!(victim_id: @user.id) do |kill|
          kill.killer_id = killer_id
        end
      else
        Kill.where(victim_id: @user.id).destroy_all
      end
    end

    redirect_to manual_input_path(user_id: @user.id), notice: "Player status updated."
  rescue ActiveRecord::RecordInvalid => error
    @users = User.order(:name, :id)
    flash.now[:alert] = error.record.errors.full_messages.to_sentence
    render :manual_edit, status: :unprocessable_entity
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :status, :qr_code, :kill_count, killed_user_ids: [])
  end

  def manual_input_params
    params.permit(:user_id, :status, :killer_id)
  end
end

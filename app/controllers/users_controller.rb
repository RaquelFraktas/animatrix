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
    victim_ids = Array(attributes[:killed_user_ids]).reject(&:blank?).map(&:to_i).uniq
    killer_id = attributes[:killer_id].presence&.to_i
    related_ids = victim_ids + [killer_id].compact

    unless User::VALID_STATUSES.include?(attributes[:status]) &&
           !related_ids.include?(@user.id) &&
           User.where(id: related_ids).count == related_ids.uniq.count
      return redirect_to manual_input_path(user_id: @user.id), alert: "Choose a valid status and other existing players."
    end

    User.transaction do
      @user.update!(status: attributes[:status])

      @user.kills_as_killer.where.not(victim_id: victim_ids).destroy_all
      victim_ids.each do |victim_id|
        kill = Kill.find_or_initialize_by(victim_id: victim_id)
        kill.update!(killer_id: @user.id) unless kill.killer_id == @user.id
      end

      current_kill = @user.kill_record
      if killer_id
        if current_kill
          current_kill.update!(killer_id: killer_id) unless current_kill.killer_id == killer_id
        else
          Kill.create!(killer_id: killer_id, victim_id: @user.id)
        end
      else
        current_kill&.destroy!
      end
    end

    redirect_to manual_input_path(user_id: @user.id), notice: "Player status and kill history updated."
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
    params.permit(:user_id, :status, :killer_id, killed_user_ids: [])
  end
end

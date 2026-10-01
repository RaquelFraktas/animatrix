class ScansController < ApplicationController
  before_action :set_user_by_qr_code, only: %i[show]

  def show
    return unless request.post?

    code = params[:qr_code].to_s.strip

    if code.blank?
      redirect_to scan_path, alert: "No QR code was provided."
      return
    end

    if @user.nil?
      redirect_to new_user_path(qr_code: code), notice: "That QR code is not attached to a player yet."
      return
    end

    if @user.name.blank?
      name = params[:target_name].to_s.strip

      if name.present?
        unless @user.update(name: name)
          render :show, status: :unprocessable_entity
          return
        end
      else
        render :show, status: :unprocessable_entity
        return
      end

      reset_session
      session[:user_id] = @user.id
      redirect_to users_path, notice: "Player name saved."
      return
    end

    killer = current_user
    unless killer&.alive?
      redirect_to scan_path(qr_code: code), alert: "Sign in as a living player before scanning."
      return
    end

    if killer == @user
      redirect_to scan_path(qr_code: code), alert: "You cannot kill yourself."
      return
    end

    if killer.kill!(@user)
      redirect_to users_path, notice: "#{@user.name} was killed by #{killer.name}."
    else
      redirect_to scan_path(qr_code: code), alert: "#{@user.name} is already dead or was already killed by you."
    end
  end


  private

  def set_user_by_qr_code
    @user = User.find_by(qr_code: params[:qr_code])
  end
end

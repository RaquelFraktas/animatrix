class ScansController < ApplicationController
  before_action :set_user_by_qr_code, only: %i[show]

  def show
    @scan_error = scan_error_message
    return unless request.post?

    code = params[:qr_code].to_s.strip

    if @user.nil?
      redirect_to new_user_path(qr_code: code), notice: "That QR code is not attached to a player yet."
      return
    end

    if @user.name.blank?
      name = params[:target_name].to_s.strip

      if name.present?
        unless @user.update(name: name)
          @user.restore_attributes([:name])
          render :show, status: :unprocessable_entity
          return
        end
      else
        render :show, status: :unprocessable_entity
        return
      end

      reset_session
      session[:user_id] = @user.id

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "scan_result",
            partial: "scans/result_frame",
            locals: { user: @user, redirect_after_kill: false }
          )
        end
        format.html do
          redirect_to scan_path(qr_code: code), notice: "Player name saved."
        end
      end
      return
    end

    if Game.locked?
      redirect_to scan_path(qr_code: code)
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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "scan_result",
            partial: "scans/result_frame",
            locals: { user: @user, redirect_after_kill: true }
          )
        end
        format.html do
          redirect_to scan_path(qr_code: code), notice: "#{@user.name} is dead."
        end
      end
    else
      redirect_to scan_path(qr_code: code), alert: "#{@user.name} is already dead or was already killed by you."
    end
  end

  def opt_out
  end


  private

  def set_user_by_qr_code
    @user = User.find_by(qr_code: params[:qr_code])
  end

  def scan_error_message
    return if @user.nil? || @user.name.blank? || current_user.nil? || current_user == @user

    if Game.locked?
      "The sentinels have arrived. No more minds can be freed."
    elsif current_user.killed?
      "You are dead. You can't free any more minds."
    elsif @user.killed?
      "#{@user.name} is already dead."
    end
  end
end

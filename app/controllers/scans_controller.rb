class ScansController < ApplicationController
  before_action :set_user_by_qr_code, only: %i[show]

  def show
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
end

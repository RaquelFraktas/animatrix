class ScansController < ApplicationController
  before_action :set_user_by_qr_code, only: %i[show]
  def show
    # @players = User.where(status: "alive").where.not(name: nil).order(:name)
    return unless request.post?
    code = params[:qr_code].to_s.strip

    killer = User.find_by(id: params[:killer_id])

    if code.blank?
      redirect_to scan_path, alert: "No QR code was provided."
      return
    end

    # unless killer&.alive?
    #   redirect_to scan_path, alert: "Choose your player before scanning."
    #   return
    # end

    # session[:user_id] = killer.id

    if @user.nil?
      redirect_to new_user_path(qr_code: code), notice: "That QR code is not attached to a player yet."
      return
    end

    if @user.name.blank?
      name = params[:target_name].to_s.strip

      if name.present?
        unless @user.update(name: name)
          # @unnamed_user = user
          render :show, status: :unprocessable_entity
          return
        end
      else
        @unnamed_user = @user
        render :show, status: :unprocessable_entity
        return
      end
    end

    # if @user.killed?
    #   redirect_to @user, notice: "#{@user.name} is already killed."
    #   return
    # end

    # if killer == @user
    #   redirect_to @user, alert: "You cannot kill yourself."
    #   return
    # end

    # killer.kill!(@user)
    # redirect_to @user, notice: "#{@user.name} was killed by #{killer.name}."
  end


  private 

  def set_user_by_qr_code
    @user = User.find_by(qr_code: params[:qr_code])
  end
end

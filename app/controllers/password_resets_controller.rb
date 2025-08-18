class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t("flash.password_resets.email_sent")
      redirect_to root_url
    else 
      flash.now[:danger] = t("flash.password_resets.email_not_found")
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find_by(email: params[:email])
    unless @user
      flash[:danger] = t("flash.password_resets.user_not_found")
      redirect_to root_url
      return
    end
    
    unless @user.activated?
      flash[:danger] = t("flash.password_resets.account_not_activated")
      redirect_to root_url
      return
    end
    
    unless @user.authenticated?(:reset, params[:id])
      flash[:danger] = t("flash.password_resets.invalid_token")
      redirect_to root_url
      return
    end
  end

  def update
    @user = User.find_by(email: params[:email])
    if @user && @user.activated? &&
       @user.authenticated?(:reset, params[:id])
      if params[:user][:password].empty?
        @user.errors.add(:password, "can't be empty")
        render 'edit', status: :unprocessable_entity
      elsif @user.update(user_params)
        @user.forget
        reset_session
        log_in @user
        flash[:success] = t("flash.password_resets.password_reset")
        redirect_to @user
      else
        render 'edit', status: :unprocessable_entity
      end
    else
      redirect_to root_url
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end

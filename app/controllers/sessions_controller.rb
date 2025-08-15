class SessionsController < ApplicationController
  include SessionsHelper

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      reset_session
      
      if params[:session][:remember_me] == '1'
        remember user
      else
        forget user
      end

      log_in user
      redirect_to user
    else
      flash.now[:danger] = t("flash.sessions.create.error")
      render 'new', status: :unprocessable_entity
    end
  end



  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end



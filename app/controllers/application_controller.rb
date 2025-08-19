class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include SessionsHelper

  private

  def logged_in_user
    unless logged_in?
      flash[:danger] = t("flash.sessions.require_login")
      redirect_to login_url
    end
  end
end

class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t("flash.users.show.error")
    redirect_to users_path
  end
  
  def index
    @users = User.paginate(page: params[:page], per_page: 2)
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = t("flash.users.create.success")
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = t("flash.users.update.success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user == current_user
      flash[:danger] = t("flash.users.destroy.error")
      redirect_to users_url
    else
      @user.destroy
      flash[:success] = t("flash.users.destroy.success")
      redirect_to users_url
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = t("flash.sessions.require_login")
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(@user) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end

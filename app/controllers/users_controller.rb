class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :activated_user, only: [:index, :show]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :following, :followers]
  def new
    @user = User.new
  end
  
  def show
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t("flash.users.show.error")
    redirect_to users_path
  end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page], per_page: 2)
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end
  
  def update
    if @user.update(user_params)
      flash[:success] = t("flash.users.update.success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      flash[:danger] = t("flash.users.destroy.error")
      redirect_to users_url
    else
      @user.destroy
      flash[:success] = t("flash.users.destroy.success")
      redirect_to users_url
    end
  end

  def following
    @title = "Following"
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end



  def correct_user
    redirect_to(@user) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def activated_user
    unless current_user&.activated?
      flash[:warning] = t("flash.users.not_activated")
      redirect_to root_url
    end
  end

  def set_user
    @user = User.find(params[:id])
  end
end

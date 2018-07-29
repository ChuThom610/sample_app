class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new show create)
  before_action :load_user, except: %i(index new create)
  before_action :verify_admin!, only: :destroy
  before_action :correct_user, only: %i(edit update)

  def index
    @users = User.activated_user.load_data
                 .paginate(page: params[:page], per_page: Settings.per_page)
  end

  def show
    @microposts = @user.microposts.paginate(page: params[:page],
                                            per_page: Settings.per_page)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "flashs.check_email"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "flashs.profile_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "flashs.user_deleted"
    else
      flash[:danger] = t "flashs.fail_delete_user"
    end
    redirect_to users_url
  end

  def following
    @title = t("users.title.following")
    @users = @user.following.paginate(page: params[:page])
    render :show_follow
  end

  def followers
    @title = t("users.title.followers")
    @users = @user.followers.paginate(page: params[:page])
    render :show_follow
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def correct_user
    redirect_to root_url unless current_user.current_user? @user
  end

  def verify_admin!
    redirect_to root_url unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "flashs.not_found_user"
    redirect_to root_path
  end
end

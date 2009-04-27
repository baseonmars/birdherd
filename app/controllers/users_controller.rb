class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
    @account = TwitterUser.new
  end

  def create
    if params[:entry_code] != SITE[:entry_code]
      flash[:notice] = "Please re-type the entry code"
      redirect_to new_user_session_path and return
    end
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default user_twitter_users_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_url
    else
      render :action => :edit
    end
  end

end

class TwitterUsersController < ApplicationController
  before_filter :require_user
  
  def index
    @user = @current_user
    @accounts = @user.twitter_users
  end
  
  def new
    @user = @current_user
    @account = @user.twitter_users.new
  end
  
  def create
    @user = @current_user
    @account = @user.twitter_users.new(params[:twitter_user])
    @account.users << @user
    if @account.save && @user.save
      flash[:notice] = "Twitter Account Created!"
      redirect_to user_twitter_user_url(@account.id)
    else
      flash[:notice] = "@#{@account.screen_name} has already been taken."
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
    @account = @user.twitter_users.find(params[:id], :include => :users)
    if @account.owned_by? @user
      @timeline = get_timeline(@account)
      @replies = get_replies(@account)
    end
  end
  
end

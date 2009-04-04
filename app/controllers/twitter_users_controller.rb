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
    post_user = params[:twitter_user]
    @account = build_twitter_user(post_user[:screen_name], post_user[:password])#@user.twitter_users.new(params[:twitter_user])
    # @user.twitter_users << @account
    @account.users << @user
    if @user.save && @account.save
      sync_friends(@account)
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
      @direct_messages = get_direct_messages(@account)
      @status = @account.statuses.new
    end
  end

end

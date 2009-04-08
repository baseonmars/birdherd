class TwitterUsersController < ApplicationController
  before_filter :require_user
  before_filter :get_account, :only => :show
  before_filter :update_timeline, :only => :show
  before_filter :update_replies, :only => :show
  before_filter :update_direct_messages, :only => :show
  
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
    @account = TwitterUser.find_by_screen_name(post_user[:screen_name])
    if @account
      @account.update_attribute(:password, post_user[:password])
    else
      @account = build_twitter_user(post_user[:screen_name], post_user[:password])
    end
    @account.users << @user
    if @user.save && @account.save
      sync_friends(@account)
      sync_followers(@account)
      flash[:notice] = "Twitter Account Created!"
      redirect_to user_twitter_user_url(@account.id)
    else
      flash[:notice] = "@#{@account.screen_name} has already been taken."
      render :action => :new
    end
  end
  
  def show
    if @account && @account.owned_by?(@current_user)
      @timeline = @account.friends_timeline
      @replies = @account.replies
      @direct_messages = @account.direct_messages
      @status = @account.statuses.new
    end
  end
  
  private
  
  def get_account
    begin
      @account = @current_user.twitter_users.find(params[:id], :include => [:users, :replies, :recieved_direct_messages, :sent_direct_messages])
    rescue
      @account = nil
    end
  end
  
  def update_timeline
    begin
      sync_friends_timeline(@account) unless @account.nil?
    rescue
      flash[:warning] ||= []
      flash[:warning] << "couldn't sync timeline: #{$!}"
    end
  end
  
  def update_replies
    begin
      sync_replies(@account) unless @account.nil?
    rescue
      flash[:warning] ||= []
      flash[:warning] << "couldn't sync replies: #{$!}"
    end
  end
  
  def update_direct_messages
    begin
      sync_direct_messages(@account) unless @account.nil?
    rescue
      flash[:warning] ||= []
      flash[:warning] << "couldn't sync direct_messages: #{$!}"
    end
  end

end

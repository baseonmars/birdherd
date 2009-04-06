class TwitterStatusesController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :reply]
  
  def index
    @twitter_user = TwitterUser.find(params[:twitter_user_id])
    @statuses = @twitter_user.statuses
  end
  
  def new
    @twitter_user = TwitterUser.find(params[:twitter_user_id])
    @status = @twitter_user.statuses.new
  end
  
  def create
    @user = @current_user
    begin
      twitter_user = @user.twitter_users.find(params[:twitter_user_id])
    rescue
      render :text => "You are not permitted to post statuses as an account you don't own", :status => 401
      return
    end
    
    status = twitter_user.statuses.new(params[:twitter_status])
    @response = post_status(twitter_user, status)
    if @response.save
      flash[:notice] = "Status posted!"
      redirect_to twitter_user_twitter_status_url(twitter_user, @response.id)
    else
      flash[:notice] = "@#{@response.screen_name} has already been taken."
      render :action => :new
    end
  end
  
  def show
    @twitter_user = TwitterUser.find(params[:twitter_user_id])
    @status = TwitterStatus.find(params[:id])
  end
  
  def reply
    @status = TwitterStatus.find(params[:status_id])
    begin
      @twitter_user = @current_user.twitter_users.find(params[:account_id])
      @reply = @status.reply
    rescue
      flash[:notice] = "You don't have the right to reply"
      redirect_to '/'
      return
    end
  end
end

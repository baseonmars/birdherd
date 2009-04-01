class TwitterStatusesController < ApplicationController
  before_filter :require_user, :only => [:new, :create]
  
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
    @twitter_user = @user.twitter_users.find(params[:twitter_user_id])
    @status = @twitter_user.statuses.new(params[:twitter_status])
    if @status.save
      flash[:notice] = "Twitter Account Created!"
      redirect_to twitter_user_twitter_status_url(@twitter_user, @status.id)
    else
      flash[:notice] = "@#{@status.screen_name} has already been taken."
      render :action => :new
    end
  end
  
  def show
    @twitter_user = TwitterUser.find(params[:twitter_user_id])
    @status = @twitter_user.statuses.find(params[:id])
  end
end

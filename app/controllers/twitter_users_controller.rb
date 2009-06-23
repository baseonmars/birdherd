class TwitterUsersController < ApplicationController
  before_filter :require_user
  before_filter :get_account, :only => :show

  def index
    @user = @current_user
    @accounts = @user.twitter_users
  end

  def new
    @user = @current_user
    @account = @user.twitter_users.new
  end

  def create
    @request_token = oauth_client.request_token
    session[:request_token] = @request_token.token
    session[:request_token_secret] = @request_token.secret
    # Send to twitter.com to authorize
    redirect_to @request_token.authorize_url
    return
  end

  def show
    if @account.owned_by?(@current_user)
      begin    
        @timeline = @account.friends_timeline
        @mentions = @account.mentions
        @direct_messages = @account.direct_messages
      rescue
        flash[:notice] = "Error from twitter: #{$!}"
      ensure
        @status = @account.statuses.new
      end
    else
      flash[:notice] = "You don't appear to have access to this twitter account" 
      redirect_back_or_default user_twitter_users_url
    end
  end  

  def friends_timeline
    @account = TwitterUser.find(params[:twitter_user_id])
    @statuses = @account.friends_timeline

    render :update do |page|
      page.visual_effect :highlight, "timeline", :durations => 0.4
      page.delay(0.4) do
        page.replace "timeline", :partial => "friends_timeline", :locals => { :statuses => @statuses, 
          :account => @account,
          :list_id => 'timeline'}
        end   
      end
      return
  end     
  
  def callback
    begin                         
      @account = TwitterUser.get_verified_user(*fetch_authorized_tokens)
      if !@account.owned_by?(@current_user) and @account.save
        @current_user.twitter_users << @account
        flash[:notice] = "Twitter account #{@account.screen_name} authorised."
        redirect_to user_twitter_user_path(@account) and return
      else
        redirect_to user_twitter_users_path and return
      end
    rescue
      flash[:notice] = "Authorization failed: #{$!}"
      redirect_to :action => :new
      return
    end
  end

  private
  def fetch_authorized_tokens
    access_token, access_secret = oauth_client.authorize_from_request( session[:request_token],
    session[:request_token_secret])  
    return access_token, access_secret
  end  
  
  def get_account
    begin
      @account = @current_user.twitter_users.find(params[:id], :include => [:users])
    rescue
      @account = nil
    end
  end 

end

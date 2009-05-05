class TwitterUsersController < ApplicationController
  before_filter :require_user
  before_filter :get_account, :only => :show
  before_filter :tweet_syncs, :only => :show

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
    if @account && @account.owned_by?(@current_user)    
      @timeline = @account.friends_timeline_with_limit(30, :include => [:replies, :poster] )
      @replies = @account.replies(:include => [:replies, :poster], :limit => 30)
      @direct_messages = @account.direct_messages(:include => [:sender, :recipient])[0...30]
      @status = @account.statuses.new
    end
  end  
  
  def friends_timeline
    @account = TwitterUser.find(params[:twitter_user_id])
    @statuses = @account.friends_timeline[0...30]

    sync_statuses(:friends_timeline, @account)

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
    # Exchange the request token for an access token.
    begin
      access_token, access_secret = oauth_client.authorize_from_request( session[:request_token],
      session[:request_token_secret])

      oauth = oauth_client
      oauth.authorize_from_access(access_token, access_secret)
      client = Twitter::Base.new(oauth)
    rescue
      flash[:notice] = "Authentication failed"
      redirect_to :action => :new
      return
    end

    user = verify_credentials(client)

    # We have an authorized user, save the information to the database.
    @account = TwitterUser.find_or_initialize_by_id(user.id)

    if @account.owned_by?(@current_user)
      flash[:notice] = "Account not added. You already have access to #{@account.screen_name}"
      redirect_to user_twitter_users_path and return
    end
    @account.update_from_twitter(user)
    @account.attributes = { :access_token => access_token, :access_secret => access_secret }

    #sync followers and followers

    if @account.save
      @current_user.twitter_users << @account
      spawn do
        sync_relationships(:follower, @account)
        sync_relationships(:friend, @account)
        @account.save
      end

      # Redirect to account list page
      flash[:notice] = "Twitter account #{@account.screen_name} authorised, your followers will be synced shortly."
      redirect_to user_twitter_user_path(@account) and return
    else
      # The user might have rejected this application. Or there was some other error during the request.
      flash[:notice] = "Authentication failed"
      redirect_to :action => :new and return
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
  
  def tweet_syncs
    sync_statuses(:friends_timeline, @account)
    sync_statuses(:replies, @account)
    sync_dms(@account)
  end

  def verify_credentials(client)
    user = client.verify_credentials
    unless user.screen_name
      flash[:notice] = "Twitter Authentication failed, was your password correct?"
      redirect_to :action => :new and return
    end
    user
  end

end

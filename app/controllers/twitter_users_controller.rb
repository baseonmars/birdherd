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
      @timeline = @account.friends_timeline
      @replies = @account.replies.find(:all, :include => [:replies, :poster], :limit => 30)
      @direct_messages = @account.direct_messages_with_limit(30, :include => [:sender, :recipient])
      @status = @account.statuses.new
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
    # Exchange the request token for an access token.
    client, access_token, access_secret = get_authorized_client_and_tokens_or_redirect
    user = get_user_credentials_or_redirect(client)

    @account = TwitterUser.merge(user)                      
    @account.attributes = { :access_token => access_token, :access_secret => access_secret }
        
    # TODO write a test for this.
    redirect_if_account_already_owned( @account )

    if @account.save
      @current_user.twitter_users << @account      
      sync_friends_and_followers(@account)

      flash[:notice] = "Twitter account #{@account.screen_name} authorised, your followers will be synced shortly."
      redirect_to user_twitter_user_path(@account) and return
    else
      # The user might have rejected this application. Or there was some other error during the request.
      flash[:notice] = "Authentication failed"
      redirect_to :action => :new and return
    end

  end

  private 
  
  def get_authorized_client_and_tokens_or_redirect
    begin
      access_token, access_secret = oauth_client.authorize_from_request( session[:request_token],
      session[:request_token_secret])

      oauth = oauth_client
      oauth.authorize_from_access(access_token, access_secret)
      client = Twitter::Base.new(oauth)
      return client, access_token, access_secret
    rescue
      flash[:notice] = "Authentication failed"
      redirect_to :action => :new
      return
    end    
  end  
  
  
  def get_account
    begin
      @account = @current_user.twitter_users.find(params[:id], :include => [:users, :replies, :recieved_direct_messages, :sent_direct_messages])
    rescue
      @account = nil
    end
  end 
  
  def get_user_credentials_or_redirect(client)
    user = client.verify_credentials
    unless user.screen_name
      flash[:notice] = "Twitter Authentication failed, was your password correct?"
      redirect_to :action => :new and return
    end
    user
  end
  
  def tweet_syncs
    sync_statuses(:replies, @account)
    sync_dms(@account)
  end

  def redirect_if_account_already_owned(account)
     if account.owned_by?(current_user)
      flash[:notice] = "Account not added. You already have access to #{account.screen_name}"
      redirect_to user_twitter_users_path and return
    end
  end 
  
  def sync_friends_and_followers(account)
    spawn do
      sync_relationships(:follower, account)
      sync_relationships(:friend, account)
      account.save
    end
  end

end

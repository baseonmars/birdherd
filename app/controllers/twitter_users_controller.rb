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
    if @account && @account.owned_by?(@current_user)
      sync_statuses(:friends_timeline, @account)
      sync_statuses(:replies, @account)
      sync_dms(@account)
      @account.reload
      @timeline = @account.friends_timeline
      @replies = @account.replies
      @direct_messages = @account.direct_messages
      @status = @account.statuses.new
    end
  end

  def callback

    # Exchange the request token for an access token.
    begin
      access_token, access_secret = oauth_client.authorize_from_request( session[:request_token],
      session[:request_token_secret])

      oauth_client.authorize_from_access(access_token, access_secret)
      client = Twitter::Base.new(oauth_client)
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

    @account.attributes = { :screen_name => user.screen_name,
      :access_token => access_token,
    :access_secret => access_secret }

    #sync followers and followers

    if @account.save
      @current_user.twitter_users << @account

      sync_relationships(:followers, @account)
      sync_relationships(:friends, @account)

      # Redirect to account list page
      flash[:notice] = "Twitter account #{@account.screen_name} authorised"
      redirect_to user_twitter_users_path and return
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

  def oauth_client
    @oauth ||= @oauth = Twitter::OAuth.new('gEn3FWqYxpDq4lQdjzA', 'gGR18W7oPFptkDBgjbMnM22hprv1KYZ2rMYZviXsZg')
  end

  def twitter_api(account)
    oauth_client.authorize_from_access(account.access_token, account.access_secret)
    Twitter::Base.new(oauth_client)
  end

  def verify_credentials(client)
    user = client.verify_credentials
    unless user.screen_name
      flash[:notice] = "Twitter Authentication failed, was your password correct?"
      redirect_to :action => :new and return
    end
    user
  end

  def sync_relationships(type, account)
    page = 1
    twitter_users = twitter_api(account).send(type, :page => page)
    while twitter_users.length.remainder(100) == 0
      page++
      twitter_users << twitter_api(account).send(type, :page => page)
    end
    account.update_relationships(type, twitter_users)
  end

  def sync_statuses(type, account)
    if account.send("#{type}_sync_time").nil? || account.send("#{type}_sync_time") < 2.5.minutes.ago
      account.update_attribute("#{type}_sync_time", Time.now)
      statuses = twitter_api(account).send(type)
      statuses.each do |api_status|
        status = TwitterStatus.find_or_initialize_by_id(api_status.id)
        status.update_from_twitter(api_status)
        status.poster = update_twitter_user(api_status.user)
        status.save
      end
    end
  end

  def sync_dms(account)
    if account.direct_messages_sync_time.nil? || account.direct_messages_sync_time < 2.5.minutes.ago
      account.update_attribute(:direct_messages_sync_time, Time.now)
      recieved = twitter_api(account).direct_messages
      sent = twitter_api(account).direct_messages_sent

      dms = sent + recieved
      dms.each do |api_dm|
        dm = TwitterDirectMessage.find_or_initialize_by_id(api_dm.id)
        dm.update_from_twitter(api_dm)
        dm.sender = update_twitter_user(api_dm.sender)
        dm.recipient = update_twitter_user(api_dm.recipient)
        dm.save
      end
    end
  end

  def update_twitter_user(api_user)
    twitter_user = TwitterUser.find_or_initialize_by_id(api_user.id)
    twitter_user.update_from_twitter(api_user)
  end

end

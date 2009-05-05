# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'twitter'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  helper_method :current_user_session, :current_user, :get_twitter
  before_filter :errors #array of error message strings

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    if current_user
      logger.debug { "Next friends sync 10 mins after #{current_user.last_friends_sync}" }
      sync_all_users_relationships(current_user) if current_user.requires_friends_sync?
    else
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url and return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to user_url and return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  def oauth_client
    Twitter::OAuth.new(SITE[:api_key], SITE[:api_secret])
  end

  def twitter_api(account)
    oauth = oauth_client
    oauth.authorize_from_access(account.access_token, account.access_secret)
    Twitter::Base.new(oauth)
  end

  def update_twitter_user(api_user)
    twitter_user = TwitterUser.find_or_initialize_by_id(api_user.id)
    if (twitter_user.new_record? || api_user.screen_name != twitter_user.screen_name)
      twitter_user.update_from_twitter(api_user).save
    end
    twitter_user
  end

  def sync_statuses(type, account)
    if account.send("#{type}_sync_time").nil? || account.send("#{type}_sync_time") < 2.5.minutes.ago
      account.update_attribute("#{type}_sync_time", Time.now)
      spawn do
        options  = account.send("#{type}_last_id").nil? ? {} : {:since_id => account.send("#{type}_last_id")}
        statuses = twitter_api(account).send( type, options.merge(:count => 30) )

        statuses.each do |api_status|
          status = TwitterStatus.find_or_initialize_by_id(api_status.id)
          status.update_from_twitter(api_status) if status.new_record?
          status.poster = update_twitter_user(api_status.user)
          status.save
        end
        account.update_attribute("#{type}_last_id", statuses.first.id) unless statuses.empty?
      end
    end
  end

  def sync_dms(account)
    if account.direct_messages_sync_time.nil? || account.direct_messages_sync_time < 2.5.minutes.ago
      account.update_attribute(:direct_messages_sync_time, Time.now)
      spawn do
        r_options = account.recieved_dms_last_id.nil? ? {} : {:since_id => account.recieved_dms_last_id}
        s_options = account.sent_dms_last_id.nil? ? {} : {:since_id => account.sent_dms_last_id}
        recieved  = twitter_api(account).direct_messages( r_options.merge(:count => 15) ) || []
        sent      = twitter_api(account).direct_messages_sent( s_options.merge(:count => 15) ) || []
        dms       = sent + recieved

        dms.each do |api_dm|
          dm = TwitterDirectMessage.find_or_initialize_by_id(api_dm.id)
          dm.update_from_twitter(api_dm) if dm.new_record?
          dm.sender = update_twitter_user(api_dm.sender)
          dm.recipient = update_twitter_user(api_dm.recipient)
          dm.save
        end
        account.update_attribute(:sent_dms_last_id, sent.first.id) unless sent.empty?
        account.update_attribute(:recieved_dms_last_id, recieved.first.id) unless recieved.empty?
      end
    end
  end
  
  def sync_relationships(type, account)
    page = 1
    twitter_user_ids = twitter_api(account).send("#{type}_ids", :page => page)
    while twitter_user_ids.length > 0 && twitter_user_ids.length.remainder(100) == 0
      page += 1
      twitter_user_ids.push *twitter_api(account).send("#{type}_ids", :page => page)
    end
    account.update_relationships(type, twitter_user_ids)
  end

  def sync_all_users_relationships(user)
    user.update_attribute(:last_friends_sync, Time.now)
    spawn do
      user.twitter_users.each do |account|
        begin
          api_user = twitter_api(account).verify_credentials
          logger.info { "#{api_user.inspect}" }
          sync_relationships(:friend, account) if api_user.friends_count != account.friends.count
          sync_relationships(:follower, account) if api_user.followers_count != account.followers.count
          account.save
        rescue
          flash[:notice] ||= ""
          flash[:notice] <<  "Rate limit exceeded for #{account.screen_name}"
          current_user.last_friends_sync = 10.minutes.from_now
        end
      end
    end
  end

  def sync_search(search)
    Twitter::Search.new(search.tag_list).each do |status|
    end
  end

  def errors
    @errors = []
  end

end

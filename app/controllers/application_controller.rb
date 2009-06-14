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
    unless current_user
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
    TwitterUser.merge(api_user)
  end

  def sync_relationships(type, account)
    page = 1
    twitter_user_ids = twitter_api(account).send("#{type}_ids", :page => page)
    while (twitter_user_ids.length > SITE[:social_graph_ids_per_page] && 
      twitter_user_ids.length % SITE[:social_graph_ids_per_page] == 0)
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
          (flash[:notice] ||= "") <<  "Rate limit exceeded for #{account.screen_name}"
          current_user.last_friends_sync = 10.minutes.from_now
        end
      end
    end
  end

  def errors
    @errors = []
  end

end

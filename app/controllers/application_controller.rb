# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'twitter'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  helper_method :current_user_session, :current_user, :get_twitter
  
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
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to dashboard_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def twitter_client(screen_name, password)
      @twitter_client ||= Twitter::Base.new(screen_name, password)
    end

# TODO DRY up the blocks in get_methods, can't work out syntax
    def get_timeline(account, type=:friends)
      if account.friends_timeline_sync_time.nil? || account.friends_timeline_sync_time < 5.minute.ago
        account.update_attribute(:friends_timeline_sync_time, Time.now)
        timeline = twitter_client(account.screen_name, account.password).timeline(type).map do |api_status|
          status = TwitterStatus.find_or_create_by_id(api_status.id)
          status.update_from_twitter(api_status)
          poster = TwitterUser.find_or_create_by_id(api_status.user.id)
          poster.update_from_twitter(api_status.user).save
          status.poster = poster
          status.save
          status
        end
      end
      account.friends_timeline
    end
    
    def get_replies(account)
      timeline = twitter_client(account.screen_name, account.password).replies.map do |api_status|
        status = TwitterStatus.find_or_create_by_id(api_status.id)
        status.update_from_twitter(api_status)
        poster = TwitterUser.find_or_create_by_id(api_status.user.id)
        poster.update_from_twitter(api_status.user).save
        status.poster = poster
        status.save
        status
      end
    end
    
    def get_direct_messages(account)
      timeline = twitter_client(account.screen_name, account.password).direct_messages.map do |api_dm|
        status = TwitterStatus.find_or_create_by_id(api_dm.id)
        status.update_from_twitter(api_dm)
        poster = TwitterUser.find_or_create_by_id(api_dm.sender_id)
        poster.screen_name = api_dm.sender_screen_name
        status.poster = poster
        status.save
        status
      end
    end
    
    def sync_friends(account)
      friends = twitter_client(account.screen_name, account.password).friends.map do |api_friend|
        friend = TwitterUser.find_or_create_by_id(api_friend.id)
        friend.update_from_twitter(api_friend)
        friend
      end

      account.friends << friends.reject do |friend|
        account.friends.include?(friend)
      end
      account.save
    end
    
    def build_twitter_user(screen_name, password)
      TwitterUser.new(:password => password).update_from_twitter( twitter_client(screen_name, password).user(screen_name) )
    end
      
end

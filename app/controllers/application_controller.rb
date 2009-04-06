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
      if account.friends_timeline_sync_time.nil? || account.friends_timeline_sync_time < 2.5.minute.ago
        account.update_attribute(:friends_timeline_sync_time, Time.now)
        twitter_client(account.screen_name, account.password).timeline(type).each do |api_status|
          status = TwitterStatus.find_or_create_by_id(api_status.id)
          status.update_from_twitter(api_status)
          poster = TwitterUser.find_or_create_by_id(api_status.user.id)
          poster.update_from_twitter(api_status.user).save
          status.poster = poster
          status.save
        end
      end
      account.friends_timeline
    end
    
    def get_replies(account)
      if account.replies_sync_time.nil? || account.replies_sync_time < 2.5.minutes.ago
        account.update_attribute(:replies_sync_time, Time.now)
        twitter_client(account.screen_name, account.password).replies.each do |api_status|
          status = TwitterStatus.find_or_create_by_id(api_status.id)
          status.update_from_twitter(api_status)
          poster = TwitterUser.find_or_create_by_id(api_status.user.id)
          poster.update_from_twitter(api_status.user).save
          status.poster = poster
          status.save
        end
      end
      account.replies
    end
    
    def get_direct_messages(account)
      if account.direct_messages_sync_time.nil? || account.direct_messages_sync_time < 2.5.minutes.ago
        account.update_attribute(:direct_messages_sync_time, Time.now)
        recieved = twitter_client(account.screen_name, account.password).direct_messages
        sent = twitter_client(account.screen_name, account.password).sent_messages
        all = recieved + sent
        all.each do |api_dm|
          dm = TwitterDirectMessage.find_or_create_by_id(api_dm.id)
          dm.update_from_twitter(api_dm)
          dm.sender = TwitterUser.find_or_create_by_id(api_dm.sender_id)
          dm.sender.screen_name = api_dm.sender_screen_name
          dm.recipient = TwitterUser.find_or_create_by_id(api_dm.recipient_id)
          dm.recipient.screen_name = api_dm.recipient_screen_name
          dm.save
          dm.sender.save
          dm.recipient.save
        end
        
      end
      account.direct_messages
    end
    
    def sync_friends(account)
      account.friends = twitter_client(account.screen_name, account.password).friends.map do |api_friend|
        friend = TwitterUser.find_or_create_by_id(api_friend.id)
        friend.update_from_twitter(api_friend)
        friend.save
        friend
      end
      account.save
    end
    
    def sync_followers(account)
      followers = twitter_client(account.screen_name, account.password).followers.map do |api_follower|
        follower = TwitterUser.find_or_create_by_id(api_follower.id)
        follower.update_from_twitter(api_follower)
        follower.save
        follower
      end
      account.followers = followers
      account.save
    end

    def build_twitter_user(screen_name, password)
      TwitterUser.new(:password => password).update_from_twitter( twitter_client(screen_name, password).user(screen_name) )
    end
    
    def post_status(account, status)
      response = twitter_client(account.screen_name, account.password).post( status.text, :in_reply_to_status_id => status.in_reply_to_status_id, :source => 'birdherd' )
      status = account.statuses.find_or_create_by_id(response.id)
      status.update_from_twitter(response)
      status
    end
    
    def errors
      @errors = []
    end
      
end

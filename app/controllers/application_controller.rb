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

  def oauth_client
    @oauth ||= @oauth = Twitter::OAuth.new('gEn3FWqYxpDq4lQdjzA', 'gGR18W7oPFptkDBgjbMnM22hprv1KYZ2rMYZviXsZg')
  end

  def twitter_api(account)
    oauth_client.authorize_from_access(account.access_token, account.access_secret)
    Twitter::Base.new(oauth_client)
  end

  def update_twitter_user(api_user)
    twitter_user = TwitterUser.find_or_initialize_by_id(api_user.id)
    twitter_user.update_from_twitter(api_user) if twitter_user.new_record?
    twitter_user
  end

  def sync_statuses(type, account)
    if account.send("#{type}_sync_time").nil? || account.send("#{type}_sync_time") < 2.5.minutes.ago
      account.update_attribute("#{type}_sync_time", Time.now)

      options  = account.send("#{type}_last_id").nil? ? {} : {:since_id => account.send("#{type}_last_id")}
      statuses = twitter_api(account).send( type, options )

      statuses.each do |api_status|
        status = TwitterStatus.find_or_initialize_by_id(api_status.id)
        status.update_from_twitter(api_status) if status.new_record?
        status.poster = update_twitter_user(api_status.user)
        status.save
      end
      account.update_attribute("#{type}_last_id", statuses.first.id) unless statuses.empty?
    end
  end

  def sync_dms(account)
    if account.direct_messages_sync_time.nil? || account.direct_messages_sync_time < 2.5.minutes.ago
      account.update_attribute(:direct_messages_sync_time, Time.now)

      r_options = account.recieved_dms_last_id.nil? ? {} : {:since_id => account.recieved_dms_last_id}
      s_options = account.sent_dms_last_id.nil? ? {} : {:since_id => account.sent_dms_last_id}
      recieved  = twitter_api(account).direct_messages( r_options ) || []
      sent      = twitter_api(account).direct_messages_sent( s_options ) || []
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

  def sync_search(search)
    Twitter::Search.new(search.tag_list).each do |status|

    end
  end

  def errors
    @errors = []
  end

end

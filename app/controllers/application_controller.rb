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

  def errors
    @errors = []
  end

end

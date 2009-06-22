require 'test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
  
  context "Logged in with one account" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
      @account = Factory :real_twitter_user, :users => [@user], :screen_name => 'birdherd', :id => 25256654
    end
    
    should "get index" do
      get '/user/accounts'
    end
    
    should "show" do
      get '/user/accounts/25256654'
    end
    
  end
end

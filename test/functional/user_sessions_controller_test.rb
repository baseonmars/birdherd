require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  context "when not logged in" do
    should "be sent back to the home/sign in page when failing" do
      post :create, :user_session => {:login => 'notreal', :password => 'wrong'}
      assert_response 401
    end
  
    should "log in an existing user, taking them to their accounts page" do
      u = Factory :user
      post :create, :user_session => {:login => u.login, :password => u.password }
      assert_redirected_to user_twitter_users_path
    end
    
    should "log out a logged in user" do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
      post :destroy
      assert_redirected_to new_user_session_path
    end
  
  end
end
require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  context "when not logged in" do
    should "be sent back to the home/sign in page when failing" do
      post :create, :user_session => {:login => 'notreal', :password => 'wrong'}
      assert_response 401
    end
  end
end
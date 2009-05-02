require 'test_helper'

class RepliesControllerTest < ActionController::TestCase
  
  context "a twitter user with a reply" do
     setup do
        @account = Factory :twitter_user
        @reply = Factory :twitter_status, :in_reply_to_user_id => @account.id
     end                                                                    
     
     should "see the reply" do
        get :index, :twitter_user_id => @account.id
        assert assigns(:replies).include?( @reply ), "Replies #{assigns(:replies).inspect} did not include reply #{@reply.id}"
        assert_response :success
     end
    
  end
  
end
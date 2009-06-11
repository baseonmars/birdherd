require 'test_helper'

class MentionsControllerTest < ActionController::TestCase
  
  context "a twitter user with a reply" do
     setup do
        @account = Factory :twitter_user
        @api_status = Factory :api_status, :in_reply_to_user_id => @account.id
     end                                                                    
     
     should "see the reply" do
        Twitter::Base.any_instance.expects(:replies).returns([@api_status])
        get :index, :twitter_user_id => @account.id
        assert_equal @api_status.id, assigns(:mentions).first.id
        assert_response :success
     end
    
  end
  
end
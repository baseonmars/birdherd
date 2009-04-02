require 'test_helper'

class TwitterUserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context "owned by a user" do
    setup do
     @user = Factory(:user)
     @twitter_user = Factory(:twitter_user)
     @twitter_user.users << @user
     @twitter_user.save
     @user.reload
    end
    
    should "agree that it is owned by a user" do
      assert @twitter_user.owned_by?(@user)
    end
    
    should "return false if owned by no one" do
      new_user = Factory(:twitter_user)
      assert !new_user.owned_by?(@user)
    end
  end
end

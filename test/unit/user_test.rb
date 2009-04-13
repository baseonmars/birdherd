require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  should_have_and_belong_to_many :twitter_users
  should_have_many :statuses, :direct_messages
  
  context "a user" do
    setup do
      @user = Factory(:user)
    end
    
    should "build a status belonging to it's self" do
      status = @user.statuses.build
      assert_equal status.birdherd_user, @user
    end
    
    should "build a direct message belonging to it" do
      dm = @user.direct_messages.build
      assert_equal dm.birdherd_user, @user
    end
    
  end
end

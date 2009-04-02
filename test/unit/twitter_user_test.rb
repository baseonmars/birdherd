require 'test_helper'

class TwitterUserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context "a twitter user" do
    setup do
      @twitter_user = Factory(:twitter_user)
    end

    should "update its attributes from an api user" do
      @twitter_user.update_from_twitter Factory.build(:api_user)
    end

    context "owned by a user" do
      setup do
        @user = Factory(:user)
        @twitter_user.users << @user
        @twitter_user.save
        @user.reload
      end

      should "agree that it is owned by a user" do
        assert @twitter_user.owned_by?(@user)
      end

      context "with updated attributes from an api user" do
        setup do
          @twitter_user.update_from_twitter Factory.build(:api_user, :id => 23423423)
        end

        should "still be owned by it's previous owner" do
          assert @twitter_user.owned_by?(@user)
        end
      end
      
      should "return false if owned by no one" do
        new_user = Factory(:twitter_user)
        assert !new_user.owned_by?(@user)
      end
      
      should "return when it was last updated from the api" do
        assert_kind_of Time, @twitter_user.last_api_access
      end
    end
  end
end

require 'test_helper'

class TwitterUserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context "a twitter user" do
    setup do
      @twitter_user = Factory(:twitter_user)
    end

    should_have_and_belong_to_many :users
    should_have_many :statuses, :friends

    should "update its attributes from an api user" do
      @twitter_user.update_from_twitter Factory.build(:api_user)
    end

    should "have friends" do
      assert @twitter_user.respond_to?(:friends)
    end

    should "have followers" do
      assert @twitter_user.respond_to?(:followers)
    end

    context "with a friend, but no followers" do
      setup do
        @friend = Factory(:twitter_user, :id => '7733932')
        @twitter_user.friends << @friend
        @friend.statuses << Factory(:twitter_status)
        @twitter_user.statuses << Factory(:twitter_status)
      end
      
      should "have one friend" do
        assert !@friend.nil?
        assert @twitter_user.friends.count, 1
        assert_kind_of TwitterUser, @twitter_user.friends.first
        assert_equal @twitter_user.friends.first, @friend
      end
      
      should "have no followers" do
        assert @twitter_user.followers.count, 0
        assert_equal @twitter_user.followers.first, nil
      end
      
      should "be a follower of the friend" do
        assert @friend.followers.include?(@twitter_user)
      end
      
      should "get timeline of friends statuses" do
        assert @twitter_user.respond_to?(:friends_timeline)
        assert_equal @twitter_user.friends_timeline.length, 2
      end
      
      should "includes friends statuses in friends timeline" do
        assert @friend.statuses.all? { |status| @twitter_user.friends_timeline.include? status }
      end
      
      should "includes own statuses in friends timeline" do
        assert @twitter_user.statuses.all? { |status| @twitter_user.friends_timeline.include? status }
      end

    end
    
    context "with 2 friend and one follower" do
      setup do
        @friend1, @friend2 = Factory(:twitter_user), Factory(:twitter_user)
        @follower = Factory(:twitter_user)
        @twitter_user.friends << [@friend1, @friend2]
        @follower.friends << @twitter_user
      end
      
      should "should have 2 friends" do
        assert_equal @twitter_user.friends.count, 2
      end
      
      should "have 1 follower" do
        assert_equal @twitter_user.followers.count, 1
      end
    end
    
    context "owned by a user" do
      setup do
        @user = Factory(:user)
        @twitter_user.users << @user
        # @twitter_user.save
        # @user.reload
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
    end
  end
end

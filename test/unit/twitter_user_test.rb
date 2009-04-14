require 'test_helper'

class TwitterUserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context "a twitter user" do
    setup do
      @twitter_user = Factory(:twitter_user)
    end

    should_have_and_belong_to_many :users
    should_have_many :statuses, :friends, :replies, :sent_direct_messages, :recieved_direct_messages
    should_have_many :searches

    should "update its attributes from an api user" do
      api_user = Factory.build(:api_user)
      @twitter_user.update_from_twitter api_user
      assert_equal @twitter_user.screen_name, api_user.screen_name
    end
    
    should "keep track of the last id it pulled for timeline, reply and dm's" do
      assert_respond_to @twitter_user, :friends_timeline_last_id
      assert_respond_to @twitter_user, :replies_last_id
      assert_respond_to @twitter_user, :sent_dms_last_id
      assert_respond_to @twitter_user, :recieved_dms_last_id
    end

    should "update it's followers from api users" do
      api_users = [Factory.build(:api_user), Factory.build(:api_user), Factory.build(:api_user)]
      @twitter_user.update_relationships(:followers, api_users)
      assert_equal @twitter_user.followers.count, api_users.length
    end

    should "update it's friends from api users" do
      api_users = [Factory.build(:api_user), Factory.build(:api_user), Factory.build(:api_user)]
      @twitter_user.update_relationships(:friends, api_users)
      assert_equal @twitter_user.friends.count, api_users.length
    end

    context "after syncing followers" do
      setup do
        @api_users = [Factory.build(:api_user, :id => 5), Factory.build(:api_user, :id => 6), Factory.build(:api_user, :id => 7)]
        @twitter_user.update_relationships(:followers, @api_users)
      end

      should "be able to sync friends which include followers" do
        api_users = @api_users + [Factory.build(:api_user, :id => 8)]
        @twitter_user.update_relationships(:friends, api_users)
        assert_equal @twitter_user.friends.count, api_users.length
      end
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
        Factory(:twitter_status, :poster => @friend)
        Factory(:twitter_status, :poster => @twitter_user)
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
      
      should "allow timelime to be limited" do
        assert_equal @twitter_user.friends_timeline(:limit => 1).length, 1
      end

      should "includes friends statuses in friends timeline" do
        assert @friend.statuses.all? { |status| @twitter_user.friends_timeline.include? status }
      end

      should "includes own statuses in friends timeline" do
        assert @twitter_user.statuses.all? { |status| @twitter_user.friends_timeline.include? status }
      end

      should "has many replies" do
        assert @twitter_user.respond_to?(:replies)
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

      # context "with updated attributes from an api user" do
      #        setup do
      #          @twitter_user.update_from_twitter Factory.build(:api_user, :id => 23423423)
      #        end
      #
      #        should "still be owned by it's previous owner" do
      #          assert @twitter_user.owned_by?(@user)
      #        end
      #      end

      should "return false if owned by no one" do
        new_user = Factory(:twitter_user)
        assert !new_user.owned_by?(@user)
      end
    end

    context "with 1 sent and 1 recieved direct message" do
      setup do
        @other_user = Factory(:twitter_user)
        @sent_message = Factory(:twitter_direct_message, :sender => @twitter_user, :recipient => @other_user)
        @recieved_message = Factory(:twitter_direct_message, :sender => @other_user, :recipient => @twitter_user)
        @twitter_user.reload
      end

      should "have one sent direct message" do
        assert_equal @twitter_user.sent_direct_messages.count, 1
      end

      should "have one recieved direct message" do
        assert_equal @twitter_user.recieved_direct_messages.count, 1
      end

      should "have two direct messages" do
        assert_equal @twitter_user.direct_messages.count, 2
      end
    end
  end
end

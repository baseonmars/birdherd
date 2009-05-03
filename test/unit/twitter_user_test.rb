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
      ids = [2323,44545,23322324]
      @twitter_user.update_relationships(:follower, ids)
      assert_equal @twitter_user.followers.count, ids.length
    end

    should "update it's friends from api users" do
      ids = [34534,234234,12312]
      @twitter_user.update_relationships(:friend, ids)
      assert_equal @twitter_user.friends.count, ids.length
    end

    context "after syncing followers" do
      setup do
        @api_users = [Factory.build(:api_user, :id => 5), Factory.build(:api_user, :id => 6), Factory.build(:api_user, :id => 7)]
        @twitter_user.update_relationships(:follower, @api_users)
      end

      should "be able to sync friends which include followers" do
        api_users = @api_users + [Factory.build(:api_user, :id => 8)]
        @twitter_user.update_relationships(:friend, api_users)
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
        assert_equal 1, @twitter_user.friends_timeline(:limit => 1).length
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

    context "with friends and followers" do
      setup do
        @friends = (1..5).to_a.map { Factory(:twitter_user) }
        @followers = (1..5).to_a.map { Factory(:twitter_user) }
        @twitter_user.friends << @friends
        @twitter_user.followers << @followers
      end

      should "remove twitter users they no longer follow when syncing" do
        current_followers = @followers[2..4] + [Factory(:twitter_user)]
        removed_followers = @followers - current_followers
        
        ids = current_followers.map { |f| f.id}
                
        @twitter_user.update_relationships(:follower, ids)

        assert @twitter_user.followers.none? { |follower| removed_followers.include?(follower) }
        assert_equal current_followers.length, @twitter_user.followers.count
      end
      
      should "correctly sync when it has two accounts with mutual relations" do
        @twitter_user2 = Factory(:twitter_user)
        @friends2 = (1..5).to_a.map { Factory(:twitter_user) }
        @followers2 = (1..5).to_a.map { Factory(:twitter_user) }
        @twitter_user2.friends << @friends2
        @twitter_user2.followers << @followers2
        @twitter_user2.friends << @twitter_user
        @twitter_user.followers << @twitter_user2
        @twitter_user.friends << @twitter_user2

        current_followers = @followers[2..4] + [Factory(:twitter_user), @twitter_user]
        removed_followers = @followers - current_followers
        
        ids = current_followers.map { |f| f.id}

        @twitter_user2.update_relationships(:follower, ids)
        
        assert @twitter_user2.followers.none? { |follower| removed_followers.include?(follower) }
        assert_equal current_followers.length, @twitter_user2.followers.count
        
      end
      
    end
      
  end
end

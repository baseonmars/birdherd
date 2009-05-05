require 'test_helper'

class TwitterUsersControllerTest < ActionController::TestCase

  context "A logged in Birdherd user with an account" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
      @account = Factory :real_twitter_user, :users => [@user]
    end
    
    context "with protected friends that are not followers" do

      setup do
        @friend = Factory(:twitter_user)
        @friend.statuses << Factory(:twitter_status) 
        @friend.protected = true
        @account.friends << @friend
      end

      should "not show their statuses" do
        get :show, :id => @account.id
        timeline = assigns(:timeline)

        posters = timeline.map { |status| status.poster }
        assert !posters.include?(@friend)
      end

    end
  end



  context "Logged in with one account" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
      @account = Factory :real_twitter_user, :users => [@user], :screen_name => 'birdherd', :id => 25256654
      # TODO remove the save and reloads. if they're not required.
      # @account.save
      friend = Factory :twitter_user, :screen_name => 'baseonmars', :id => 7733932
      @account.friends << friend
      # @user.reload
    end

    should "see a list of all it's twitter accounts" do
      get :index
      assert_response :success
      assert_not_nil assigns(@accounts)
    end

    should "create a new user" do
      get :new
      assert_response :success
    end

    should "create a new user belonging to them" do
      post :create, :twitter_user => Factory.attributes_for(:twitter_user)
      assert_redirected_to 'http://twitter.com/authorize'
      post :callback
      assert_redirected_to user_twitter_user_path(assigns(:account))
    end

    should "update the account from the twitter api" do
      post :create, :twitter_user => Factory.attributes_for(:twitter_user)
      post :callback
      assert_no_match /^Account not added/, flash[:notice]
      assert @user.twitter_users.find_by_screen_name('birdherd')
    end

    should "updates the accounts friends and followers from the api" do
      Spawn.now_yields do
        post :create, :twitter => Factory.attributes_for(:twitter_user)
        post :callback         
      end
      assert_equal 4, assigns(:account).followers.count, "followers don't match"
      assert_equal 6, assigns(:account).friends.count, "friends don't match"
    end
    
    should "only get the id's of friends and followers" do
      post :create, :twitter => Factory.attributes_for(:twitter_user)
      post :callback
    end

    should "show a twitter account" do
      get :show, :id => @account.id
      assert_response :success
      assert_not_nil assigns('account')
    end

    should "see the public timeline for an account they own" do
      get :show, :id => @account.id
      assert_not_nil assigns('account')
      assert_not_nil assigns('timeline')
    end

    context "when getting statuses" do
      setup do
        @start_time = Time.now
        Spawn.now_yields do
          get :show, :id => @account.id
        end
        assert_response :success
      end

      should "update the friends timeline sync time" do
        assert_not_nil assigns('account').friends_timeline_sync_time
        assert assigns('account').friends_timeline_sync_time = @start_time
        assert_response :success
      end

      should "not sync friends timeline if synced in last 2.5 minutes" do
        last_sync = assigns('account').friends_timeline_sync_time
        pretend_now_is(2.3.minutes.from_now) do
          get :show, :id => @account.id
          assert_equal assigns('account').friends_timeline_sync_time.to_s, last_sync.to_s
        end
      end
      
      should "update the friends timeline last sync id" do
        get :show, :id => @account.id
        assert_equal assigns('account').friends_timeline_last_id, 1483410281
      end

      should "update the replies sync time" do
        assert assigns('account').replies_sync_time
      end

      should "update the replies on the twitter user" do
        assert_equal assigns('account').replies.count, 4
        assert_equal assigns('replies').length, 4
      end

      should "update the friends timeline on the twitter user" do
        assert assigns('account').friends_timeline.length > 0
      end

      should "not sync replies if synced in last 2.5 minutes" do
        last_sync = assigns('account').replies_sync_time
        pretend_now_is(2.3.minutes.from_now) do
          get :show, :id => @account.id
          assert_equal assigns('account').replies_sync_time.to_s, last_sync.to_s
        end
      end
      
      should "update the replies last sync id" do
        assert_equal assigns('account').replies_last_id, 1465564830
      end

      should "updated the direct messages sync time" do
        assigns assigns('account').direct_messages_sync_time
      end
      
      should "update the direct messages on the twitter user" do
        assert_equal assigns('account').direct_messages.count, 3
      end
      
      should "update the last sync id for sent dm's" do
        assert_equal assigns('account').sent_dms_last_id, 87516211
      end
      
      should "update the last sync id for recieved dm's" do
        assert_equal assigns('account').recieved_dms_last_id, 89724222
      end
    end
    
    context "when account is created" do

      setup do
        post :callback
      end

      should "be redirected to user_twitter_user_path" do
        assert_redirected_to user_twitter_user_path(assigns(:account))
      end

    end

  end

  context "not logged in" do
    should "not be able to create a new user" do
      get :new
      assert_redirected_to new_user_session_path
      post :create, :twitter_user => Factory.attributes_for(:twitter_user)
      assert_redirected_to new_user_session_path
    end

    should "require a login to list twitter accounts" do
      get :index
      assert_redirected_to new_user_session_path
    end


  end


end

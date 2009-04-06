require 'test_helper'

class TwitterUsersControllerTest < ActionController::TestCase  

  context "Logged in with one account" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
      @account = Factory :real_twitter_user, :users => [@user]
      @account.save
      @user.reload
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
      assert_not_nil assigns('account')
      assert_redirected_to user_twitter_user_path(assigns('account').id)
      assert assigns('account').owned_by?(@user)
    end
    
    should "update the account from the twitter api" do
      post :create, :twitter_user => Factory.attributes_for(:twitter_user)
      assert assigns('account')
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
    
    should "fill a twitter user with the statuses it recieves" do
      get :show, :id => @account.id
      assert assigns('timeline').length, TwitterStatus.count
    end
    
    context "when getting statuses" do
      setup do
        @start_time = Time.now
        get :show, :id => @account.id
      end

      should "update the friends timeline sync time" do
        assert assigns('account').friends_timeline_sync_time > @start_time
      end

      should "not sync friends timeline if synced in last 2.5 minutes" do
        last_sync = assigns('account').friends_timeline_sync_time
        pretend_now_is(2.3.minutes.from_now) do
          get :show, :id => @account.id
          assert_equal assigns('account').friends_timeline_sync_time.to_s, last_sync.to_s
        end
      end

      should "update the replies sync time" do
        assert assigns('account').replies_sync_time
      end

      should "not sync replies if synced in last 2.5 minutes" do
        last_sync = assigns('account').replies_sync_time
        pretend_now_is(2.3.minutes.from_now) do
          get :show, :id => @account.id
          assert_equal assigns('account').replies_sync_time.to_s, last_sync.to_s
        end
      end

      should "updated the direct messages sync time" do
        assigns assigns('account').direct_messages_sync_time
      end

      should "set the poster on statuses it recieves" do
        get :show, :id => @account.id
      end
      
    end
    
    
    
    context "viewing their dashboard" do
      setup do
        get :show, :id => @account.id
      end
      should "see a timeline of tweets" do
        assert assigns(:timeline)
      end
      
      should "see all their replies" do
        assert assigns(:replies)
      end
      
      should "see direct messages sent to them" do
        assert assigns(:direct_messages)
      end
      
      should "be have a new status ready to post" do
        assert assigns(:status)
      end
    end
    
      
  end

  context "logged in with no accounts" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
    end
    should "create a new user" do
      get :new
      assert_response :success
      post :create, :twitter_user => Factory.attributes_for(:twitter_user)
      assert_redirected_to user_twitter_user_path(assigns('account').id)
      assert_not_nil assigns('account')
      assert assigns(:account).owned_by?(@user)
    end
  end
  
  context "not logged in" do
    should "not be able to create a new user" do
      get :new
      assert_redirected_to new_user_session_path 
      post :create, :twitter_user => Factory.attributes_for(:twitter_user)
      assert_redirected_to new_user_session_path 
    end

    should "not be able to list twitter accounts" do
      get :index
      assert_redirected_to new_user_session_path
    end
  end
end

require 'test_helper'

class TwitterUsersControllerTest < ActionController::TestCase

  context "Logged in with one account" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
      @account = Factory :real_twitter_user, :users => [@user], :screen_name => 'birdherd', :id => 25256654
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
      fol_c, fri_c = 4,6
      api_user = Factory :api_user, 
        :followers_count => fol_c, :friends_count => fri_c
      Twitter::Base.any_instance.expects(:verify_credentials).returns(api_user)

      post :callback         

      assert_equal fol_c, assigns(:account).followers_count, "followers don't match"
      assert_equal fri_c, assigns(:account).friends_count, "friends don't match"
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

    context "when getting statuses with a yielding spawn" do
      setup do
        @start_time = Time.now
        Spawn.now_yields do
          get :show, :id => @account.id
        end
        assert_response :success
      end

      should "update the mentions on the twitter user" do
        assert_equal assigns('account').mentions.length, 4
        assert_equal assigns('mentions').length, 4
      end

      should "update the friends timeline on the twitter user" do
        assert assigns('account').friends_timeline.length > 0
      end
     
      should "update the direct messages on the twitter user" do
        assert_equal assigns('account').direct_messages.length, 3
      end
    end  
    
    context "when getting statuses with a forking spawn" do
      setup do
        @start_time = Time.now
        get :show, :id => @account.id
        assert_response :success
      end 
            
    end
    
    context "when account is created" do

      setup do
        @followers_count, @friends_count = 6, 12                                                                    
        api_user = Factory :api_user, 
          :followers_count => @followers_count,
          :friends_count => @friends_count     
        Twitter::Base.any_instance.expects(:verify_credentials).returns(api_user)
        post :callback
        @account = assigns(:account)
      end

      should "be redirected to user_twitter_user_path" do
        assert_redirected_to user_twitter_user_path(@account)
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

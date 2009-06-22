require 'test_helper'

class TwitterStatusesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  context "logged out user" do

    should "see all statuses for a given twitter user" do
      get :index, :twitter_user_id => Factory(:twitter_user).id
      assert_response :success
      assert_not_nil assigns(:statuses)
      assert_kind_of TwitterUser, assigns(:twitter_user)
    end

    should "show a status for a given twitter user" do
      twitter_user = Factory(:twitter_user)
      status = Factory(:twitter_status)
      get :show, :id => status.id, :twitter_user_id => twitter_user.id
      assert_response :success
    end

    should "require a login to add a new status" do
      get :new
      assert_redirected_to new_user_session_path
    end

    should "require a login to post a new status" do
      twitter_user = Factory(:twitter_user)
      post :create, :twitter_user_id => twitter_user.id, :status => Factory.build(:twitter_status, :poster => twitter_user)
      assert_redirected_to new_user_session_path
    end
    
    should "require a login to reply to a status" do
      twitter_user = Factory(:twitter_user)
      post :reply, :twitter_user_id => twitter_user.id, :status => Factory.build(:twitter_status, :poster => twitter_user)
      assert_redirected_to new_user_session_path
    end
  end

  context "a logged in user" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
    end

    should "see all statuses for a given twitter user" do
      get :index, :twitter_user_id => Factory(:twitter_user).id
      assert_response :success
      assert_not_nil assigns(:statuses)
      assert_kind_of TwitterUser, assigns(:twitter_user)
    end

    context "with a twitter user linked as an account" do
      setup do
        @twitter_user = Factory(:twitter_user)
        @original_poster = Factory(:twitter_user, :screen_name => 'original_poster')
        @user.twitter_users << @twitter_user
        @status = Factory(:twitter_status, :poster => @twitter_user)
      end

      should "be able to reply to a status on an account they 'own'" do
        get :reply, :account_id => @twitter_user.id, :status_id => @status.id
        assert_response :success
        assert_template :reply
        assert_kind_of TwitterStatus, assigns(:reply)
        reply = assigns(:reply)
        reply.text = 'this is a reply'
        post :create, :twitter_user_id => @twitter_user.id, :twitter_status => reply.attributes
        assert_redirected_to user_twitter_user_path(@twitter_user)
        assert flash[:warning].nil?, "flash not empty #{flash.inspect}"
      end

      should "be able to reply to a status of an account they don't 'own'" do
        get :reply, :account_id => @twitter_user.id, :status_id => @status.id
        reply = assigns(:reply)
        reply.text = 'this is a reply'
        post :create, :twitter_user_id => @twitter_user.id, :twitter_status => reply.attributes
        assert_redirected_to user_twitter_user_path(@twitter_user)
        assert flash[:warning].nil?, "flash not empty #{flash.inspect}"
      end

      should "not be able to create a post belonging to an account they don't own" do
        new_post = Factory.attributes_for(:twitter_status, :poster => @original_poster)
        post :create, :twitter_user_id => @original_poster.id, :twitter_status => new_post
        assert_response 401
      end
      
      should "be marked as the new statuses birdherd_user" do
        new_post = Factory.attributes_for(:twitter_status, :poster => @original_poster)
        post :create,:twitter_user_id => @twitter_user.id, :twitter_status => new_post
        assert_equal assigns(:tweet).birdherd_user, @user
      end
      
      should "post a status" do
        new_post = Factory.attributes_for(:twitter_status, :poster => @original_poster)
        post :create, :twitter_user_id => @twitter_user.id, :twitter_status => new_post
        assert_equal assigns(:tweet).birdherd_user, @user
      end
      
      should "post a direct_message" do
        new_post = Factory.attributes_for(:twitter_status, :text => 'd baseonmars here be words')
        Twitter::Base.any_instance.expects(:direct_message_create).with('baseonmars', 'here be words').returns(Factory(:api_message))
        post :create, :twitter_user_id => @twitter_user.id, :twitter_status => new_post
      end
    end

  end

end

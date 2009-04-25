require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context "when not logged in" do

    should "require login to view dashboard" do
      get :show
      assert_redirected_to new_user_session_path
    end

    should "require login to edit" do
      get :edit
      assert_redirected_to new_user_session_path
    end

    should "require login to update" do
      get :update
      assert_redirected_to new_user_session_path
    end

    should "be able to register a new user" do
      get :new
      assert_response :success
      post :create, :user => Factory.attributes_for(:user)
      assert_redirected_to user_twitter_users_path
      assert_kind_of User, assigns('user')
    end

  end

  context "a logged in user" do
    setup do
      activate_authlogic
      UserSession.create Factory.build(:user)
      @user = User.find(1)
    end

    should "be able to view their dashbaord" do
      get :show
      assert_response :success
      assert_template 'show'
      assert_not_nil assigns('user')
      assert_equal assigns('user'), @user
    end

    should "be able to edit their account" do
      get :edit
      assert_response :success
      assert_template 'edit'
      assert_not_nil assigns('user')
      assert_equal assigns('user'), @user
    end

    context "with an account" do
      setup do
        @user.twitter_users << Factory(:twitter_user)
      end

      should "be able to update their account" do
        get :update, :user => {:login => 'jimbob'}
        assert_response :redirect
        assert_template :show
        assert_equal assigns('user').login, 'jimbob'
      end

      should "sync all it's twitter_users friends on request" do
        before_friends_sync = 0.minutes.ago
        pretend_now_is(11.minutes.from_now) do
          get :show
          assert before_friends_sync < assigns(:user).last_friends_sync
        end
      end
    end

    context "with more than one account" do
      setup do
        accounts = [Factory(:twitter_user), Factory(:twitter_user), Factory(:twitter_user)]
        accounts.each { |acc|
          acc.friends << [Factory(:twitter_user), Factory(:twitter_user), Factory(:twitter_user)]
          acc.followers << [Factory(:twitter_user), Factory(:twitter_user), Factory(:twitter_user)]
        }
        @user.twitter_users << accounts
      end
    end

  end

end

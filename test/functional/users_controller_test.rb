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
      post :create, :user => Factory.attributes_for(:user), :entry_code => SITE[:entry_code]
      assert_redirected_to user_twitter_users_path
      assert_kind_of User, assigns('user')
    end
    
    should "require a code to register a new user" do
      post :create, :user => Factory.attributes_for(:user), :entry_code => SITE[:entry_code]
      assert_redirected_to user_twitter_users_path
    end
    
    should "be redirected if entering the wrong code" do
      post :create, :user => Factory.attributes_for(:user), :entry_code => 'wrong code'
      assert_redirected_to new_user_session_path
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

    end

  end

end

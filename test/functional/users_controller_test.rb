require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context "when not logged in" do
    setup do

    end

    should "require login to view dashboard" do
      get :show
      assert_redirected_to new_user_session_path
    end

    should "require login to edit" do
      get :edit
      assert_redirected_to new_user_session_path
    end

    should  "require login to update" do
      get :update
      assert_redirected_to new_user_session_path
    end

    should "be able to register a new user" do
      get :new
      assert_response :success
      post :create, :user => { :login => 'new', :password => 'password', :password_confirmation => 'password'}
      assert_redirected_to dashboard_path
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
  end

end

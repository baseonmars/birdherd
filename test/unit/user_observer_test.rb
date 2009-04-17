require 'test_helper'

class UserObserverTest < ActiveSupport::TestCase

  context "a User Observer" do
    setup do
      ActionMailer::Base.deliveries = []
    end

    context "after a user signs up" do

      setup do
        @user = Factory :user
      end

      should "send a welcome email to the user" do
        mail = UserMailer.create_welcome_email(@user)
        assert_equal 1, ActionMailer::Base.deliveries.length
        assert_equal mail.encoded, ActionMailer::Base.deliveries.first.encoded
      end

    end

  end
end

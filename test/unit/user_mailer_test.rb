require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  context "a user mailer" do
    setup do
      @user = Factory :user, :login => 'mailer_tester', :email => 'test@example.com'
    end
    
    should "welcome a user" do
      @expected.from    = "#{SITE[:email_str]}"
      @expected.to      = @user.email
      @expected.subject = "Welcome to The Birdherd"
      @expected.body    = read_fixture('welcome_email')
      @expected.date    = Time.now
      
      assert_equal @expected.encoded, UserMailer.create_welcome_email(@user).encoded
      assert_match /#{SITE[:url]}/, UserMailer.create_welcome_email(@user).body
    end
  end
end

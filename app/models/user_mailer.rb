class UserMailer < ActionMailer::Base
  
  def welcome_email(user)
    recipients    user.email
    from          SITE[:email]
    subject       "Welcome to #{SITE[:app_name]}"
    sent_on       Time.now
    body          :user => user
  end
end

Factory.sequence :login do |n| 
  "user_name_#{n}" 
end

Factory.sequence :screen_name do |n|
  "screen_name_#{n}"
end

Factory.define :user do |f|
  f.login { Factory.next :login }
  f.password "password"
  f.password_confirmation "password"
end

Factory.define :twitter_user do |f|
  f.screen_name { Factory.next :screen_name }
  f.password "password"
  f.last_api_access Time.now
end

Factory.define :real_twitter_user, :class => 'twitter_user' do |f|
  f.screen_name 'birdherd'
  f.password 'karm4dude'
  f.last_api_access Time.now
end

Factory.define :twitter_status do |f|
  f.text "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
end

Factory.define :api_status, :class => Twitter::Status do |f|
 f.favorited false
 f.created_at "Tue Mar 31 19:07:33 +0000 2009"
 f.text "bob bob"
 f.in_reply_to_user_id ""
 f.in_reply_to_status_id " "
 f.source "web"
 f.truncated false
end

Factory.define :api_user, :class => Twitter::User do |f|
  f.profile_image_url "http://static.twitter.com/images/default_profile_normal.png"
  f.followers_count "0"
  f.name "Bird Herd"
  f.protected false
  f.description ""
  f.screen_name "birdherd"
  f.url ""
end
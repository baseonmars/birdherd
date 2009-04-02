Factory.sequence :login do |n| 
  "user_name_#{n}" 
end

Factory.define :user do |f|
  f.login { Factory.next :login }
  f.password "password"
  f.password_confirmation "password"
end

Factory.define :twitter_user do |f|
  f.screen_name { Factory.next :login }
  f.password "password"
end

Factory.define :real_twitter_user, :class => 'twitter_user' do |f|
  f.screen_name 'birdherd'
  f.password 'karm4dude'
end

Factory.define :twitter_status do |f|
  f.text "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
end

Factory.define :api_status, :class => Twitter::Status do |f|
 f.favorited false
 f.created_at "Tue Mar 31 19:07:33 +0000 2009"
 f.text "bob bob"
 f.in_reply_to_user_id ""
 # f.user <Twitter::User:0x33a0720 @location=""
 # f.profile_image_url "http://static.twitter.com/images/default_profile_normal.png"
 # f.followers_count "0"
 # f.name "Bird Herd"
 # f.protected false
 # f.description ""
 # f.screen_name "birdherd"
 # # f.id "25256654"
 # f.url ""
 f.in_reply_to_status_id " "
 f.source "web"
 f.truncated false
end
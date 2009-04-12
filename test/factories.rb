Factory.sequence :login do |n| 
  "user_name_#{n}" 
end

Factory.sequence :screen_name do |n|
  "screen_name_#{n}"
end

Factory.sequence :api_user_id do |n|
  "123456#{n}"
end

Factory.define :user do |f|
  f.login { Factory.next :login }
  f.password "password"
  f.password_confirmation "password"
end

Factory.define :twitter_user do |f|
  f.screen_name { Factory.next :screen_name }
end

Factory.define :twitter_direct_message do |f|
  f.sender {|sender| sender.association(:twitter_user) }
  f.text 'this is a direct message'
  f.recipient {|recipient| recipient.association(:twitter_user) }
  f.created_at 15.minutes.ago
end

Factory.define :real_twitter_user, :class => 'twitter_user' do |f|
  f.screen_name { Factory.next :screen_name }
end

Factory.define :twitter_status do |f|
  f.text "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
  f.poster { |poster| poster.association(:twitter_user) }
end

Factory.define :api_user, :class => Mash do |f|
  f.screen_name { Factory.next :screen_name }
end
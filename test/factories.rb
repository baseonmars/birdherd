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
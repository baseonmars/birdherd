class Friendship < ActiveRecord::Base
  belongs_to :twitter_user
  belongs_to :friend, :class_name => 'TwitterUser', :foreign_key => 'friend_id'
end

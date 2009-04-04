class Friendship < ActiveRecord::Base
  belongs_to :friend, :class_name => 'TwitterUser'
  belongs_to :follower, :class_name => 'TwitterUser'
end

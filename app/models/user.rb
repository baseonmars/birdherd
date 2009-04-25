class User < ActiveRecord::Base
  has_and_belongs_to_many :twitter_users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => 'birdherd_user_id'
  has_many :direct_messages, :class_name => "TwitterDirectMessage", :foreign_key => 'birdherd_user_id'
  acts_as_authentic
  
  def requires_friends_sync?
    return true
    last_friends_sync.nil? || (last_friends_sync < 10.minutes.ago)
  end
end

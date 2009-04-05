class TwitterUser < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "poster_id"
  has_many :replies , :class_name => 'TwitterStatus', :foreign_key => 'in_reply_to_user_id'
  
  has_many :sent_direct_messages, :class_name     => 'TwitterDirectMessage', :foreign_key => 'sender_id'
  has_many :recieved_direct_messages, :class_name => 'TwitterDirectMessage', :foreign_key => 'recipient_id'
  has_many :direct_messages, :class_name          => 'TwitterDirectMessage', :finder_sql  => 'SELECT * from twitter_direct_messages WHERE sender_id = #{id} OR recipient_id = #{id}'

  has_many :follower_friendships, :class_name => 'Friendship',  :foreign_key => 'follower_id'
  has_many :followers, :class_name            => 'TwitterUser', :through     => :friend_friendships, :source => :follower
  has_many :friend_friendships, :class_name   => 'Friendship',  :foreign_key => 'friend_id'  
  has_many :friends, :class_name              => 'TwitterUser', :through     => :follower_friendships, :source => :friend
  
  
  
  def owned_by?(user)
    @users.include? user unless @users.nil?
  end

  def update_from_twitter(api_user)
    api_user.instance_variables.each do |attrib|
      if attrib.nil? || attrib == '@status'
        next
      end
      attrib.gsub!(/^@/,'')
      if self.respond_to?(attrib)
        self.send("#{attrib}=", api_user.send(attrib))
      end
    end
    self
  end
  
  def friends_timeline
    friends_statuses = friends.inject([]) do |acc,friend|
      acc + friend.statuses
    end 
    friends_statuses + statuses
  end
  
end

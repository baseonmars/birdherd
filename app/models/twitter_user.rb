class TwitterUser < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "poster_id"
  has_many :replies , :class_name => 'TwitterStatus', :foreign_key => 'in_reply_to_user_id', :order => 'created_at DESC'

  has_many :sent_direct_messages, :class_name     => 'TwitterDirectMessage', :foreign_key => 'sender_id', :order => 'created_at DESC'
  has_many :recieved_direct_messages, :class_name => 'TwitterDirectMessage', :foreign_key => 'recipient_id', :order => 'created_at DESC'
  has_many :direct_messages, :class_name          => 'TwitterDirectMessage', :finder_sql  => 'SELECT * from twitter_direct_messages WHERE sender_id = #{id} OR recipient_id = #{id} ORDER BY created_at DESC'

  has_many :follower_friendships, :class_name => 'Friendship',  :foreign_key => 'follower_id'
  has_many :followers, :class_name            => 'TwitterUser', :through     => :friend_friendships, :source => :follower
  has_many :friend_friendships, :class_name   => 'Friendship',  :foreign_key => 'friend_id'
  has_many :friends, :class_name              => 'TwitterUser', :through     => :follower_friendships, :source => :friend

  has_many :searches

  has_many :friends_timeline , 
    :class_name => 'TwitterStatus', 
    :finder_sql => %q{SELECT * from twitter_statuses 
      WHERE poster_id = #{id} OR 
      poster_id in (#{friends.map {|f| f.id}.join(",")})
      ORDER BY created_at DESC
    }



  def owned_by?(user)
    users.include? user unless users.nil?
  end

  def update_from_twitter(api_user)
    api_user.each { |k,v| self.send("#{k}=", v) if self.respond_to?(k) }
    self
  end

  def update_relationships(type, api_user_ids)
    users = []
    api_user_ids.each do |api_id|
      user = TwitterUser.find_or_initialize_by_id(api_id)
      users << user
    end
    self.send("#{type}s").replace(users)
    self
  end

  def visible_to?(other)
    unprotected || followers.include?(other)
  end

  private
  def unprotected
    !self.protected
  end

end



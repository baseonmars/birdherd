class TwitterUser < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "poster_id"
  has_many :replies , :class_name => 'TwitterStatus', :foreign_key => 'in_reply_to_user_id', :order => 'created_at DESC'

  has_many :sent_direct_messages, :class_name     => 'TwitterDirectMessage', :foreign_key => 'sender_id', :order => 'created_at DESC'
  has_many :recieved_direct_messages, :class_name => 'TwitterDirectMessage', :foreign_key => 'recipient_id', :order => 'created_at DESC'
  has_many :direct_messages, :class_name          => 'TwitterDirectMessage', 
  :finder_sql  => %q{SELECT * from twitter_direct_messages 
    WHERE sender_id = #{id} OR 
    recipient_id = #{id} 
    ORDER BY created_at DESC
    LIMIT #{timeline_limit||1000}
  }

  has_many :follower_friendships, :class_name => 'Friendship',  :foreign_key => 'follower_id'
  has_many :followers, :class_name            => 'TwitterUser', :through     => :friend_friendships, :source => :follower
  has_many :friend_friendships, :class_name   => 'Friendship',  :foreign_key => 'friend_id'
  has_many :friends, :class_name              => 'TwitterUser', :through     => :follower_friendships, :source => :friend

  has_many :searches
                    
  def friends_timeline
    TwitterStatus.friends_timeline(account_api)
  end
      
  def direct_messages_with_limit(limit=30, options={})
    @timeline_limit = limit
    timeline = direct_messages()
    @timeline_limit = nil
    timeline
  end

  def owned_by?(user)
    users.include? user unless users.nil?
  end
              
  # TODO - remove
  def update_from_twitter(api_user)
     TwitterUser.merge api_user
  end

  def self.merge(api_user)
    user = TwitterUser.find_or_initialize_by_id(api_user.id)
    api_user.each { |k,v| user.send("#{k}=", v) if user.respond_to?("#{k}=") } 
    user
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

  protected
    attr_accessor :timeline_limit           

  private     
          
    def unprotected
      !self.protected
    end  
    
    def oauth_client
      Twitter::OAuth.new(SITE[:api_key], SITE[:api_secret])
    end

    def account_api
      oauth = oauth_client
      oauth.authorize_from_access(access_token, access_secret)
      Twitter::Base.new(oauth)
    end     

end



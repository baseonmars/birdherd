class TwitterUser < ActiveRecord::Base
  include Ziggy
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "sender_id"  
  cached( :history, :direct_messages_sent, :direct_messages_recieved, :mentions, :expire_after => 1.minutes ) { |twitter_user| twitter_user.screen_name }
   
  LIMIT = 30

  def friends_timeline(options={})
    opts = {:limit => LIMIT}.merge options
    TwitterStatus.merge_all account_api.friends_timeline(:count => opts[:limit]) || []
  end
  
  def direct_messages_sent(options={})
    opts = {:limit => LIMIT}.merge options
    TwitterDirectMessage.merge_all account_api.direct_messages_sent(:count => opts[:limit]) || []
  end
  
  def direct_messages_recieved(options={})
    opts = {:limit => LIMIT}.merge options
    TwitterDirectMessage.merge_all account_api.direct_messages(:count => opts[:limit]) || []
  end
  
  def user_timeline(options={})
    opts = {:limit => LIMIT}.merge options       
    TwitterStatus.merge_all account_api.user_timeline(:count => opts[:limit]) || []
  end 
  
  def mentions(options={})
    opts = {:limit => LIMIT}.merge options
    TwitterStatus.merge_all account_api.replies(:count => opts[:limit])
  end
  
  def history(options={})
    opts = {:limit => LIMIT}.merge options
    (user_timeline + direct_messages_sent).sort {|a,b| 
      b.created_at.to_i <=> a.created_at.to_i}[0...opts[:limit]]
  end
  
  def direct_messages(options={})
    opts = {:limit => LIMIT}.merge options
    messages = (direct_messages_sent + direct_messages_recieved).sort {|a,b|
      b.created_at <=> a.created_at}[0...opts[:limit]]
  end  
  
  def post_update(tweet, bh_user)
    if tweet.text =~ /^d \w+\s/i
      user, text = tweet.text.scan(/^d (\w+) (.*)/i).flatten
      api_message = account_api.direct_message_create(user, text)
      message = TwitterDirectMessage.merge api_message
      message.birdherd_user = bh_user
      message.save
      return message
    else
      api_status = account_api.update( tweet.text,
        :in_reply_to_status_id => tweet.in_reply_to_status_id,
        :source => 'birdherd' )
      status = TwitterStatus.merge api_status
      status.birdherd_user = bh_user
      status.save
      return status
    end  
  end

  def owned_by?(user)
    users.include? user unless users.nil?
  end 
  
  def verify_credentials
    TwitterUser.merge account_api.verify_credentials
  end 
    
  def merge!(api_user)
    raise "Id's do not match" if id != api_user[:id]
    return if api_user.nil?
    api_user.each { |k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") }
  end
  
  def self.get_verified_user(a_token, a_secret)
    user = new(:access_token => a_token, :access_secret => a_secret)
    user = user.verify_credentials
    user.access_token, user.access_secret = a_token, a_secret
    user
  end 

  def self.merge(api_user)
    return if api_user.nil?
    user = TwitterUser.find_or_initialize_by_id(api_user.id)
    api_user.each { |k,v| user.send("#{k}=", v) if user.respond_to?("#{k}=") } 
    user.save if user.new_record? or user.changed?
    user
  end

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



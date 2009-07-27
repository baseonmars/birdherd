class TwitterUser < ActiveRecord::Base
  include Ziggy
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "sender_id"  
  cached( :history, :direct_messages_sent, :direct_messages_recieved, :mentions, :expire_after => 1.minutes ) { |twitter_user| twitter_user.screen_name }
   
  LIMIT = 30
 
  def direct_messages_sent(opts={})
    retrieve_direct_messages :direct_messages_sent, opts
  end
  
  def direct_messages_recieved(opts={})
    retrieve_direct_messages :direct_messages, opts
  end
  
  def friends_timeline(opts={})
    retrieve_statuses(:friends_timeline, opts)
  end
  
  def user_timeline(opts={})
    retrieve_statuses :user_timeline, opts
  end 
                                                                       
  def mentions(opts={})
    retrieve_statuses :replies, opts
  end   
  
  def history(opts={})
    limit = opts[:limit] || LIMIT
    messages = (user_timeline({:limit => limit}) + 
      direct_messages_sent({:limit => limit})).sort {|a,b| 
      b.created_at.to_i <=> a.created_at.to_i}[0...limit]
    found = false
    messages.reject { |message|
      if found
        true
      else
        found = message.id == opts[:since_id] ? true : false 
      end
      } || []   
  end
  
  def direct_messages(opts={})
    limit = opts[:limit] || LIMIT
    messages = (direct_messages_sent(opts.dup) + direct_messages_recieved(opts.dup)).sort {|a,b|
      b.created_at <=> a.created_at}[0...limit]
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
    api_user.each { |k,v| 
      self.send("#{k}=", v) if self.respond_to?("#{k}=") }
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
    
    def retrieve_statuses(type, opts={})
      options = opts[:limit] ? {:count => opts.delete(:limit)} : {:count => LIMIT} 
      options.merge! opts
      TwitterStatus.merge_all(account_api.send(type, options)) || []
    end

    def retrieve_direct_messages(type, opts={})                       
      options = opts[:limit] ? {:count => opts.delete(:limit)} : {:count => LIMIT} 
      options.merge! opts
      TwitterDirectMessage.merge_all(account_api.send(type, options)) || []
    end     

end



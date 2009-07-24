class TwitterDirectMessage < ActiveRecord::Base
  belongs_to :sender, :class_name => 'TwitterUser', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'TwitterUser', :foreign_key => 'recipient_id'
  belongs_to :birdherd_user, :class_name => 'User', :foreign_key => 'birdherd_user_id'
                 

  # TODO - remove
  def update_from_twitter(api_dm)
    api_dm.each { |k,v|
      next if ['sender','recipient'].include?(k)
    self.send("#{k}=", v) if self.respond_to?(k) }
    self
  end
  
  def update_from_api(api_message)
    api_message.delete :id       
    api_message.each do |k,v| 
      next if ['sender','recipient'].include?(k)
      self.send("#{k}=", v) if self.respond_to?("#{k}=") 
    end
    self.sender = TwitterUser.merge(api_message.sender)
    self.recipient = TwitterUser.merge(api_message.recipient)
    self.save if self.changed?
    self
  end
  
  def self.merge(api_message)
    return if api_message.nil?
    message = TwitterDirectMessage.find_or_initialize_by_id(api_message.id)

    api_message.each do |k,v| 
      next if ['sender','recipient'].include?(k)
      message.send("#{k}=", v) if message.respond_to?("#{k}=") 
    end
    message.sender = TwitterUser.merge api_message.sender
    message.recipient = TwitterUser.merge api_message.recipient
    message.save if message.new_record? or message.changed?
    message
  end
  
  def self.merge_all(api_result)
    # TODO check response for errors
    return [] if api_result.nil?    
    ids = api_result.collect { |status| status[:id] }
    messages = TwitterDirectMessage.all :conditions => "id in (#{ids.join(',')})", :include => [:sender, :recipient]
    api_result.collect do |api_message|
      if message = messages.find { |m| m.id == api_message.id}
        message.update_from_api api_message
      else 
        self.merge api_message
      end
    end
  end
         
  def replies
    []
  end
  
end

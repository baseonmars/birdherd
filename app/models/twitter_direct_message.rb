class TwitterDirectMessage < ActiveRecord::Base
  belongs_to :sender, :class_name => 'TwitterUser', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'TwitterUser', :foreign_key => 'recipient_id'
  belongs_to :birdherd_user, :class_name => 'User', :foreign_key => 'birdherd_user_id'

  def update_from_twitter(api_dm)
    api_dm.each { |k,v|
      next if ['sender','recipient'].include?(k)
    self.send("#{k}=", v) if self.respond_to?(k) }
    self
  end
end

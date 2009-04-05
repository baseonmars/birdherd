class TwitterDirectMessage < ActiveRecord::Base
  belongs_to :sender, :class_name => 'TwitterUser', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'TwitterUser', :foreign_key => 'recipient_id'
  
  def update_from_twitter(api_dm)
    api_dm.instance_variables.each do |attrib|
      if attrib.nil? || ['@sender_screen_name', '@recipient_screen_name'].include?(attrib)
        next
      end
      attrib.gsub!(/^@/,'')
      if self.respond_to?(attrib)
        self.send("#{attrib}=", api_dm.send(attrib))
      end
    end
    self
  end
end

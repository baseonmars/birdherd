class TwitterUser < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :statuses, :class_name => "TwitterStatus", :foreign_key => "poster_id"

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

end

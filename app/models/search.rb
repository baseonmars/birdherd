class Search < ActiveRecord::Base
  belongs_to :twitter_user
  
  def statuses
    TwitterStatus.find_tagged_with(tag_list)
  end
end

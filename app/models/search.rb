class Search < ActiveRecord::Base
  belongs_to :twitter_user
  
  def statuses
    Status.find_tagged_with(tag_list, :match_all => true)
  end
end

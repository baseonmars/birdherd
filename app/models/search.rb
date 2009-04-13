class Search < ActiveRecord::Base
  has_and_belongs_to_many :twitter_users
end

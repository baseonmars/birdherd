class AddFollowersAndFriendsCountToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :followers_count, :integer
    add_column :twitter_users, :friends_count, :integer
  end

  def self.down
    remove_column :twitter_users, :friends_count
    remove_column :twitter_users, :followers_count
  end
end

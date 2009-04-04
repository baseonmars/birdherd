class ApiAccessTimesOnTwitterUser < ActiveRecord::Migration
  def self.up
    remove_column :twitter_users, :last_pulled
    add_column :twitter_users, :friends_timeline_sync_time, :datetime
    add_column :twitter_users, :replies_sync_time, :datetime
    add_column :twitter_users, :direct_messages_sync, :datetime
  end

  def self.down
    remove_column :twitter_users, :direct_messages_sync
    remove_column :twitter_users, :replies_sync_time
    remove_column :twitter_users, :friends_timeline_sync_time
    add_column :twitter_users, :last_pulled, :date
  end
end

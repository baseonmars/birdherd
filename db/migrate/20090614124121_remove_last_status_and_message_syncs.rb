class RemoveLastStatusAndMessageSyncs < ActiveRecord::Migration
  def self.up
    remove_column :twitter_users, :friends_timeline_sync_time
    remove_column :twitter_users, :replies_sync_time
    remove_column :twitter_users, :direct_messages_sync_time
  end

  def self.down
    add_column :twitter_users, :direct_messages_sync_time, :datetime
    add_column :twitter_users, :replies_sync_time, :datetime
    add_column :twitter_users, :friends_timeline_sync_time, :datetime
  end
end

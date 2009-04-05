class CorrectDmSyncColumnName < ActiveRecord::Migration
  def self.up
    rename_column :twitter_users, :direct_messages_sync, :direct_messages_sync_time
  end

  def self.down
    rename_column :twitter_users, :direct_messages_sync_time, :direct_messages_sync
  end
end

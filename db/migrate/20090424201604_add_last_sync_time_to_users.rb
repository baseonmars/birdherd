class AddLastSyncTimeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_friends_sync, :datetime
  end

  def self.down
    remove_column :users, :last_friends_sync
  end
end

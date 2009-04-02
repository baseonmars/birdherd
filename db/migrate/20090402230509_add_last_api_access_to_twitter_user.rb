class AddLastApiAccessToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :last_api_access, :date
  end

  def self.down
    remove_column :twitter_users, :last_api_access
  end
end

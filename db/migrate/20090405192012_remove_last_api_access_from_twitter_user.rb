class RemoveLastApiAccessFromTwitterUser < ActiveRecord::Migration
  def self.up
    remove_column :twitter_users, :last_api_access
  end

  def self.down
    add_column :twitter_users, :last_api_access, :date
  end
end

class AddProtectedToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :protected, :boolean, :default => false
  end

  def self.down
    remove_column :twitter_users, :protected
  end
end

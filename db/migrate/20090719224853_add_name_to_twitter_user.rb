class AddNameToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :name, :string
  end

  def self.down
    remove_column :twitter_users, :name
  end
end

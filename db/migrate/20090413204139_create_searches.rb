class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.timestamps
    end
    
    create_table :searches_twitter_users, :id => false do |t|
      t.integer :twitter_user_id
      t.integer :search_id
    end
  end

  def self.down
    drop_table :searches
    drop_table :searches_twitter_users
  end
end

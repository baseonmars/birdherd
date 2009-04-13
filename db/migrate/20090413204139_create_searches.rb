class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.timestamps
      t.string :tag_list
      t.integer :twitter_user_id
    end
  end

  def self.down
    drop_table :searches
  end
end

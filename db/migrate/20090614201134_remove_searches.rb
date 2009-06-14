class RemoveSearches < ActiveRecord::Migration
  def self.up
    drop_table :searches
  end

  def self.down
    create_table "searches", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "tag_list"
      t.integer  "twitter_user_id"
    end
    
  end
end

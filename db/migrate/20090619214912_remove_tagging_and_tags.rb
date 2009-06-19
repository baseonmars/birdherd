class RemoveTaggingAndTags < ActiveRecord::Migration
  def self.up
    drop_table :tags
    drop_table :taggings
  end

  def self.down
    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "taggable_type"
      t.string   "context"
      t.datetime "created_at"
    end
    
    create_table "tags", :force => true do |t|
      t.string "name"
    end
    
  end
end

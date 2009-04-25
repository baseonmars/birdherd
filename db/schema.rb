# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090424201604) do

  create_table "friendships", :force => true do |t|
    t.integer "follower_id"
    t.integer "friend_id"
  end

  create_table "searches", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag_list"
    t.integer  "twitter_user_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "twitter_direct_messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "birdherd_user_id"
  end

  create_table "twitter_statuses", :force => true do |t|
    t.text     "text"
    t.integer  "poster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "in_reply_to_user_id"
    t.integer  "in_reply_to_status_id"
    t.integer  "birdherd_user_id"
    t.string   "cached_tag_list"
  end

  create_table "twitter_users", :force => true do |t|
    t.string   "screen_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "friends_timeline_sync_time"
    t.datetime "replies_sync_time"
    t.datetime "direct_messages_sync_time"
    t.string   "profile_image_url"
    t.string   "access_token"
    t.string   "access_secret"
    t.integer  "friends_timeline_last_id"
    t.integer  "replies_last_id"
    t.integer  "sent_dms_last_id"
    t.integer  "recieved_dms_last_id"
    t.boolean  "protected",                  :default => false
  end

  create_table "twitter_users_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "twitter_user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.datetime "last_friends_sync"
  end

end

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

ActiveRecord::Schema.define(:version => 20090105173123) do

  create_table "blog_recommendations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "blog_id"
    t.boolean  "is_new"
    t.boolean  "is_rejected"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "weight"
  end

  create_table "blogs", :force => true do |t|
    t.integer  "site_id"
    t.string   "url"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "posts", :force => true do |t|
    t.integer  "blog_id"
    t.integer  "blog_post_id"
    t.integer  "num_comments"
    t.integer  "rating_positive"
    t.integer  "rating_negative"
    t.integer  "rating_average"
    t.integer  "rating_total"
    t.text     "content"
    t.datetime "posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "title"
    t.integer  "num_reads"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.string   "address_format"
    t.string   "feed_suffix"
    t.string   "xpath_post"
    t.string   "xpath_num_comment"
    t.string   "xpath_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xpath_num_reads"
    t.string   "name"
    t.string   "xpath_positive_rating"
    t.string   "xpath_negative_rating"
    t.integer  "positive_rating_position"
    t.integer  "negative_rating_position"
    t.integer  "num_comment_position"
    t.integer  "num_read_position"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
    t.integer "user_id"
  end

  add_index "taggings", ["tag_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_type"
  add_index "taggings", ["user_id", "tag_id", "taggable_type"], :name => "index_taggings_on_user_id_and_tag_id_and_taggable_type"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"
  add_index "taggings", ["user_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_user_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0, :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["taggings_count"], :name => "index_tags_on_taggings_count"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_url"
    t.string   "login",                     :limit => 40
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "users_blogs", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "blog_id",       :null => false
    t.integer  "num_posts"
    t.integer  "num_new_posts"
    t.string   "description"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users_posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "num_old_comments"
    t.boolean  "is_read"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key",              :limit => 100
  end

  add_index "users_posts", ["key"], :name => "hashed_key_index", :unique => true

end

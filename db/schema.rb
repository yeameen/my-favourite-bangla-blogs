# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

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
    t.integer "timestamp",                  :null => false
    t.string  "server_url"
    t.string  "salt",       :default => "", :null => false
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
    t.string   "url"
    t.datetime "posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.integer  "num_reads"
  end

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
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_url"
  end

  create_table "users_blogs", :force => true do |t|
    t.integer  "user_id",                      :null => false
    t.integer  "blog_id",                      :null => false
    t.integer  "num_posts",     :default => 0
    t.integer  "num_new_posts", :default => 0
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
  end

end

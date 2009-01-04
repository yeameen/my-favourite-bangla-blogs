class AlterUsersAddSupportForRestfulAuthentication < ActiveRecord::Migration
  def self.up
    remove_column :users, :password
    add_column :users, :login,                     :string, :limit => 40
    add_column :users, :crypted_password,          :string, :limit => 40
    add_column :users, :salt,                      :string, :limit => 40
    add_column :users, :remember_token,            :string, :limit => 40
    add_column :users, :remember_token_expires_at, :datetime
    add_column :users, :activation_code,           :string, :limit => 40
    add_column :users, :activated_at,              :datetime

#    create_table "users", :force => true do |t|
#      t.string   "name"
#      t.string   "email"
#      t.string   "password"
#      t.datetime "created_at"
#      t.datetime "updated_at"
#      t.string   "identity_url"
#    end

#      t.column :login,                     :string, :limit => 40
#      t.column :name,                      :string, :limit => 100, :default => '', :null => true
#      t.column :email,                     :string, :limit => 100
#      t.column :crypted_password,          :string, :limit => 40
#      t.column :salt,                      :string, :limit => 40
#      t.column :created_at,                :datetime
#      t.column :updated_at,                :datetime
#      t.column :remember_token,            :string, :limit => 40
#      t.column :remember_token_expires_at, :datetime
#      t.column :activation_code,           :string, :limit => 40
#      t.column :activated_at,              :datetime

    add_index :users, :login, :unique => true
  end

  def self.down
    remove_index  :users, :column => :login

    remove_column :users, :login,                     :string, :limit => 40
    remove_column :users, :crypted_password,          :string, :limit => 40
    remove_column :users, :salt,                      :string, :limit => 40
    remove_column :users, :remember_token,            :string, :limit => 40
    remove_column :users, :remember_token_expires_at, :datetime
    remove_column :users, :activation_code,           :string, :limit => 40
    remove_column :users, :activated_at,              :datetime
    add_column :users, :password,                     :string, :limit => 40
  end
end

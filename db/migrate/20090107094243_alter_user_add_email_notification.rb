class AlterUserAddEmailNotification < ActiveRecord::Migration
  def self.up
    add_column :users, :email_notification, :boolean, :default => true
  end

  def self.down
    remove_column :users, :email_notification
  end
end

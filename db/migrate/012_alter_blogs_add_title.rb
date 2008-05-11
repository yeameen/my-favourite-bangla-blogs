class AlterBlogsAddTitle < ActiveRecord::Migration
  def self.up
    add_column :blogs, :title, :string
  end

  def self.down
    remove_column :blogs, :title
  end
end

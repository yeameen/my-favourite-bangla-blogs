class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.integer :site_id
      t.string :url
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end

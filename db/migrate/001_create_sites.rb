class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :address_format, :null => true
      t.string :xpath_post, :null => true
      t.string :xpath_comment, :null => true
      t.string :xpath_rating, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end

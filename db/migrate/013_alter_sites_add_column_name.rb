class AlterSitesAddColumnName < ActiveRecord::Migration
  def self.up
    add_column :sites, :name, :string
  end

  def self.down
    remove_column :sites, :name
  end
end

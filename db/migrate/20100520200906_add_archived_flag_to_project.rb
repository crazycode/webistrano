class AddArchivedFlagToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :archived, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :projects, :archived
  end
end

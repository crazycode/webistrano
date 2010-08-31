class AddCategoryToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :category, :string
    add_index :projects, :category
    add_index :projects, [:category, :archived]
  end

  def self.down
    remove_column :projects, :category
  end
end

class CreateLocalRepositories < ActiveRecord::Migration
  def self.up
    create_table :local_repositories do |t|
      t.column :stage_id, :integer
      t.timestamps!
    end
  end

  def self.down
    drop_table :local_repositories
  end
end

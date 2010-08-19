class RemoveAlertEmails < ActiveRecord::Migration
  def self.up
    remove_column :stages, :alert_emails
  end

  def self.down
    add_column :stages, :alert_emails, :text
  end
end

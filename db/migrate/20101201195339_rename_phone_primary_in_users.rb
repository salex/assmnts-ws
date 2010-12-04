class RenamePhonePrimaryInUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, "phone-primary", :phone_primary
  end

  def self.down
  end
end

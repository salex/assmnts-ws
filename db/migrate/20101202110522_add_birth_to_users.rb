class AddBirthToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birth_mm, :string, :limit => 2
    add_column :users, :birth_dd, :string, :limit => 2
  end

  def self.down
    remove_column :users, :birth_dd
    remove_column :users, :birth_mm
  end
end

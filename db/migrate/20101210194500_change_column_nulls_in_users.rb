class ChangeColumnNullsInUsers < ActiveRecord::Migration
  def self.up
    change_column_null :users, :encrypted_password, true
    change_column_null :users, :password_salt, true
  end

  def self.down
    change_column_null :users, :password_salt, false
    change_column_null :users, :password_salt, false
  end
end

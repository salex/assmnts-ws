class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      t.string   "user_type", :default => "citizen"
      t.string   "name_full"
      t.string   "name_first"
      t.string   "name_last"
      t.string   "name_mi"
      t.string   "phone-primary"
      t.string   "phone_secondary"
      t.text     "address"
      t.string   "city"
      t.string   "state"
      t.string   "zip"
      t.string   "login"
      t.string   "roles"
      t.integer  "citizen_id"
      t.string   "challenge"

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
  end
end

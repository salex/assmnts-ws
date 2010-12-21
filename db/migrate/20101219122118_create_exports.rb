class CreateExports < ActiveRecord::Migration
  def self.up
    create_table :exports do |t|
      t.string :status
      t.string :token
      t.text :request
      t.text :response
      t.integer :user_id
      t.datetime :sent
      t.datetime :received
      t.timestamps
    end
    add_index "exports", "status", :name => "index_exports_on_status"
    add_index "exports", "token", :name => "index_exports_on_token"
    
  end

  def self.down
    drop_table :exports
  end
end

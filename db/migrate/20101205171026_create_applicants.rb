class CreateApplicants < ActiveRecord::Migration
  def self.up
    create_table :applicants do |t|
      t.integer :user_id
      t.integer :stage_id
      t.decimal :score,      :precision => 8, :scale => 2
      t.text :score_object
      t.string :status
      t.date :status_date

      t.timestamps
    end
  end

  def self.down
    drop_table :applicants
  end
end

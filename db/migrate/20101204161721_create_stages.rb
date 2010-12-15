class CreateStages < ActiveRecord::Migration
  def self.up
    create_table :stages do |t|
      t.string :name
      t.string :status
      t.string :note
      t.integer :jobstage_id
      t.string :stage_name
      t.integer :job_id
      t.string :job_title
      t.integer :project_id
      t.string :project_name
      t.text :assessment_json
      t.integer :number_jobs

      t.timestamps
    end
  end

  def self.down
    drop_table :stages
  end
end

class AddWeightedToApplicants < ActiveRecord::Migration
  def self.up
    add_column :applicants, :weighted, :decimal,        :precision => 8, :scale => 2
    rename_column :applicants, :score_object, :answers
  end

  def self.down
    remove_column :applicants, :weighted
    rename_column :applicants, :answers, :score_object
    
  end
end

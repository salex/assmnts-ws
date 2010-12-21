class AddAppliedDateToApplicants < ActiveRecord::Migration
  def self.up
    add_column :applicants, :applied_date, :date
  end

  def self.down
    remove_column :applicants, :applied_date
  end
end

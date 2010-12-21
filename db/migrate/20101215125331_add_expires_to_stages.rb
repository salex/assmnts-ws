class AddExpiresToStages < ActiveRecord::Migration
  def self.up
    add_column :stages, :expires_date, :date
    add_column :stages, :ad_url, :string
  end

  def self.down
    remove_column :stages, :ad_url
    remove_column :stages, :expires_date
  end
end

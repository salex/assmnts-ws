class Assessor < ActiveRecord::Base
  belongs_to :assessment
  belongs_to :assessing, :polymorphic => true
  has_many :scores, :dependent => :destroy
  
end

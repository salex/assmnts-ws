class Assessor < ActiveRecord::Base
  belongs_to :assessment
  belongs_to :assessing, :polymorphic => true
  has_many :scores, :dependent => :destroy
  
  before_save :set_status
  
  def set_status
    self.status = self.assessing.status
  end
  
end

class Question < ActiveRecord::Base
  include Assmnt
  
  belongs_to :assessment
  has_many :answers, :order => "sequence", :dependent => :destroy
  before_validation :set_defaults
  
  after_save :updateMax
  after_destroy :updateMax
  private
  
  def set_defaults
    if (self.score_method.downcase == "sum") && ((self.answer_type.downcase == "checkbox") || (self.answer_type.downcase == "select-multiple") )
    else
      self.score_method = "Value"
    end
  end
  
  def updateMax
    computeMax(self.assessment.id) if is_dirty?
  end
  
  def is_dirty?
     dirty = false
     self.changed.each{|attrib|
       dirty =  (dirty || !( /score_method|weight|critical|minimum_value/i =~ attrib ).nil?)
     }
    return dirty
  end
  def is_dirty_broke?
    dirty =  (self.score_method_changed? or self.weight_changed? or self.critical_changed? or  self.minimum_value.changed?)
  end
end


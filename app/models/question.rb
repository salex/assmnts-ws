class Question < ActiveRecord::Base
  include Assmnt
  
  belongs_to :assessment
  has_many :answers, :order => "sequence", :dependent => :destroy
  before_validation :set_defaults
  after_save :updateMax
  after_destroy :updateMax
  accepts_nested_attributes_for :answers, :reject_if => lambda { |a| a[:answer].blank? }, :allow_destroy => true



  private
  
  def set_defaults
    if ((self.score_method.downcase == "sum") || (self.score_method.downcase == "max")) && ((self.answer_type.downcase == "checkbox") || (self.answer_type.downcase == "select-multiple") )
      self.score_method = self.score_method.capitalize
    else
      self.score_method = "Value" unless self.score_method.downcase == "none"
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


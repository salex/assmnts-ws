class Answer < ActiveRecord::Base
  belongs_to :question
  after_save :updateMax
  after_destroy :updateMax
  attr_accessor :status, :assessor_count
  
  include Assmnt
  
  def status
    question.assessment.status
  end
  
  def assessor_count
    question.assessment.assessors.count
  end
  
  def can_destroy?
    (assessor_count == 0) && (status != "Master")
  end
  
  
  private

  def updateMax
    computeMax(self.question.assessment.id) if is_dirty?
  end
  
  def is_dirty?
     dirty = false
     self.changed.each{|attrib|
       dirty =  (dirty || !( /value|answer_eval/i =~ attrib ).nil?)
     }
    return dirty
  end
  
  
end

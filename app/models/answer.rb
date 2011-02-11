class Answer < ActiveRecord::Base
  belongs_to :question
  after_save :updateMax
  after_destroy :updateMax
  
  #include Assmnt
    
  private

  def updateMax
    Assessment.computeMax(self.question.assessment.id) if is_dirty?
  end
  
  def is_dirty?
     dirty = false
     self.changed.each{|attrib|
       dirty =  (dirty || !( /value|answer_eval/i =~ attrib ).nil?)
     }
    return dirty
  end
  
  
end

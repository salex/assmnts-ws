class Score < ActiveRecord::Base
  belongs_to :assessed, :polymorphic => true
  belongs_to :assessor
  belongs_to :assessing, :polymorphic => true
  
  def self.search(params)
    scores = scoped  
    scores = scores.where(:assessor_id => params[:assessor_id]) if params[:assessor_id]  
    scores = scores.where(:assessed_id => params[:person_id]) if params[:person_id]  
    scores  
    
  end
  
  def self.get_or_create_score(assessor,params)
    if assessor.repeating
      score = nil
    else  
      # the reason for .last is the generic assmnt allow repeating assessment like instructor eval
      score = self.order(:updated_at).where(:assessor_id => assessor.id, :assessed_id => params[:model_id]).last
    end
    if score.nil?
      score = self.new
      score.assessor_id = assessor.id
      score.assessed_type = assessor.assessed_model
      score.assessed_id =  params[:model_id]
      score.assessing_type = assessor.assessing_type
      score.assessing_id = assessor.assessing_id
      score.save
    end
    return score
  end
end

#http://localhost:8080/public/ws/conv_score.a4d?fdata={%22jobstageid%22:1852,%22citizenid%22:153156}
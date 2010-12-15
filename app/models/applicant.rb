
class Applicant < ActiveRecord::Base
  belongs_to :stage
  belongs_to :user
  has_many :scores, :as => :assessed
  include Assmnt
  CAN_APPLY = "New Incomplete Complete Failed"

  def update_4d
    user = self.user
    if user.citizen_id.nil? || user.citizen_id == 0
      action = "create"
    else
      action = "update"
    end
        
    stage = {}
    
    citizen = {}
    citizen["citizen.phone1"] = user.phone_primary
    citizen["citizen.phone2"] = user.phone_secondary
    citizen["citizen.Address"] = user.address
    citizen["citizen.City"] = user.city
    citizen["citizen.state"] = user.state
    citizen["citizen.zip"] = user.zip
    citizen["citizen.firstName"] = user.name_first
    citizen["citizen.lastName"] = user.name_last
    citizen["citizen.firstName"] = user.name_first
    citizen["citizen.mi"] = user.name_mi
    citizen["citizen.emailAddress"] = user.email
    citizen["citizen.birthMMDD"] = user.birth_mm + user.birth_dd
    citizen["action"] = action
    if action == "update"
      citizen["id"] = user.citizen_id
    end
    update4d = {"citizen" => citizen}
    fdata = update4d.to_json
    citizen =  %x[curl --form-string  'fdata=#{fdata}' 'http://localhost:8080/ws.citizen.update4d']
    if citizen[0..0] == "{"
      citizen = ActiveSupport::JSON.decode(citizen)
    else
      citizen = {"error" => citizen, "fdata" => fdata}
    end
    #TODO need to evaluate at some placess if success
    return citizen
		
  end
  
  def display_profile
    scores = self.scores
    dump = ""
    scores.each do |score|
      assessor = score.assessor
      if !assessor.nil?
        qa = assessor.assessment.getQandA
        post = ActiveSupport::JSON.decode(score.score_object)
        dump << dumpPost(post,qa)
      end
    end
    return dump
  end
  
  def rescore
    assessors = self.stage.assessors
    max_raw = []
    max_weighted = []
    answers = ""
    score_raw = []
    score_weighted = []
    assessors.each do |assessor|
      assessment = assessor.assessment
      max_raw << assessment.max_raw
      max_weighted << assessment.max_weighted
      score = assessor.scores.where(:assessed_id => self.id).first
      if score.nil?
        next
      end
      area = ActiveSupport::JSON.decode(score.score_object)
      post = {"post.answer" => area["answers"], "post.answer_other" => area["answers_other"]}
      scored = assessment.scoreAssessment(post)
      score_params = {}
      score_params[:score_object] = scored.to_json
      score_params[:score] = scored["score_raw"]
      score_params[:score_weighted] = scored["score_weighted"]
      score_params[:answers]  = "|" + scored["all_answers"].join("|") + "|"
      score.update_attributes(score_params)
      score_raw << scored["total_raw"]
      score_weighted << scored["total_weighted"]
      answers << score_params[:answers] 
      score.save
    end
    if score_raw.length > 0
      1.upto(max_raw.length - 1) do |i|
        max_raw[0] += max_raw[i]
        max_weighted[0] += max_weighted[i]
        score_raw[0] += score_raw[i]
        score_weighted[0] += score_weighted[i]
      end
      self.score = max_raw[0] > 0 ? (score_raw[0] / max_raw[0]) * 100 : 0
      self.weighted = max_weighted[0] > 0 ? (score_weighted[0] / max_weighted[0]) * 100 : 0
      self.answers = answers.gsub("||","|")
      self.save
    end
    
  end
  
end

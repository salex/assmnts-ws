
class Stage < ActiveRecord::Base
  has_many :applicants
  has_many :assessors, :as => :assessing
  has_many :scores, :as => :assessing
  def stage_applicants(params)
    applicants = self.applicants.scoped
    if params[:filter]
      applicants = applicants.order("score DESC")
    else
      applicants = applicants.order("score DESC").where("status = ? OR status = ? OR status LIKE ?", "Completed", "Failed", "shit")
    end
    if params[:status] && (params[:status] != "" && params[:status] != "All")
      
      applicants = applicants.order("score DESC").where('status LIKE ?', "%#{params[:status]}%")
    end 
    if params[:name] && params[:name] != ""
      applicants = applicants.order("score DESC").joins(:user).where('users.name_full LIKE ?', "%#{params[:name]}%")
    end
    if params[:phone] && params[:phone] != ""
      applicants = applicants.order("score DESC").joins(:user).where('users.phone_primary LIKE ?', "#{params[:phone]}%")
    end
    if params[:email] && params[:email] != ""
      applicants = applicants.order("score DESC").joins(:user).where('users.phone_primary LIKE ?', "#{params[:email]}%")
    end
    
    applicants
  end
  
  def rescore
    applicants = self.applicants
    applicants.each do |applicant|
      applicant.rescore
    end
  end
  
  def get_or_create_applicant(citizen)
    applicant = Applicant.where(:stage_id => self.id, :user_id => citizen).first
    if applicant.nil?
      applicant = Applicant.new
      applicant.stage_id = self.id
      applicant.user_id = citizen
      applicant.status = "Incomplete"
      applicant.status_date = Date.today
      applicant.save
    end
    return applicant
  end
  
  def create_assessment
    hash = ActiveSupport::JSON.decode(self.assessment_json)
    seq = 0
    hash.each do |key,area|
      seq += 1
      assmnt = Assessment.new
      assmnt[:name] = "Job.#{self.job_id}"
      assmnt[:description] = self.project_name
      assmnt[:status] = "Imported"
      assmnt[:category] = "application.#{key}"
      assmnt[:xml_key] = key == "experience" ? "wh" : key[0..1]
      assmnt.save
      self.create_assessor(assmnt.id,seq)
      area.each do |qkey,question|
        ques = Question.new
        ques.assessment_id = assmnt.id
        ques.sequence = qkey.gsub(/[^0-9]/,"").to_i
        ques.shortname = question["name"]
        ques.question = question["text"]
        ques.answer_type = question["type"].downcase.include?("radio") ? "Radio" : question["type"]
        ques.display_type = question["display"].downcase.include?("line") ? "Inline" : "List"
        ques.weight = question["weight"]
        ques.critical = question["critical"]
        ques.minimum_value = question["min"]
        case question["score"].downcase
        when "sum"
          scorem = "sum"
        when "max"
          scorem = "Max"
        when "none"
          scorem = "None"
        else
          scorem = "Value"
        end
        ques.score_method = scorem
        ques.xml_key = qkey
        ques.save
        p ques.xml_key
        question["answers"].each do |akey,answer|
          ans = Answer.new
          ans.question_id = ques.id
          ans.sequence = answer["id"].to_i
          ans.shortname = answer["name"]
          ans.answer = answer["text"]
          ans.value = answer["value"].to_i
          ans.requires_other = !answer["other"].blank?
          ans.other_question = answer["other"]
          ans.xml_key = ques.xml_key + "_#{answer["id"]}"
          ans.save
          p ans.xml_key
        end
      end
    end
    
  end
  
  def create_assessors(assessment_name)
    assessments = Assessment.order(:id).where(:name => assessment_name)
    seq = 0
    assessments.each do |assessment|
      seq += 1
      test = self.assessors.where(:assessment_id => assessment.id)
      if test.nil?
        assessor = self.assessors.build
        assessor.assessment_id = assessment.id
        assessor.sequence = seq
        assessor.assessed_model = "Applicant"
        assessor.status = "New"
        assessor.repeating = false
        assessor.save
      end
    end
  end
  
  def create_assessor(assessment_id, seq=0)
    assessments = Assessment.find(assessment_id)
    assessor = self.assessors.build
    assessor.assessment_id = assessment.id
    assessor.sequence = seq
    assessor.assessed_model = "Applicant"
    assessor.status = "New"
    assessor.repeating = false
    assessor.save
  end
  
  def get_applicant_scores(applicant)
    scores = {}
    assessors = self.assessors
    assessors.each do |assessor|
      scores[assessor.assessment.category] = assessor.scores.where(:assessed_id => applicant.id)
    end
    return scores
  end
  
end

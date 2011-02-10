
class Stage < ActiveRecord::Base
  has_many :applicants
  has_many :assessors, :as => :assessing
  has_many :scores, :as => :assessing
  
  def stage_applicants(params)
    applicants = self.applicants.scoped
    if params[:filter]
      applicants = applicants.order("weighted DESC")
    else
      applicants = applicants.order("weighted DESC").where("status = ? OR status = ? OR status LIKE ?", "Completed", "Failed", "test")
    end
    if params[:status] && (params[:status] != "" && params[:status] != "All")
      applicants = applicants.where('status LIKE ?', "%#{params[:status]}%")
    end 
    if params[:name] && params[:name] != ""
      applicants = applicants.joins(:user).where('users.name_full LIKE ?', "%#{params[:name]}%")
    end
    if params[:answers] && params[:answers] != ""
      p1 = params[:answers].gsub(/(\D\d{4})/, "answers LIKE '%\\1%'")
      p2 = p1.gsub("&"," AND ")
      mywhere = p2.gsub("|", " OR ")
      applicants = applicants.where(mywhere)
    end
    if params[:phone] && params[:phone] != ""
      applicants = applicants.joins(:user).where('users.phone_primary LIKE ?', "#{params[:phone]}%")
    end
    if params[:email] && params[:email] != ""
      applicants = applicants.joins(:user).where('users.phone_primary LIKE ?', "#{params[:email]}%")
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
      applicant.applied_date = Date.today
      applicant.save
    end
    return applicant
  end
  
  def get_applicant_scores(applicant)
    scores = {}
    assessors = self.assessors
    assessors.each do |assessor|
      scores[assessor.assessment.category] = assessor.scores.where(:assessed_id => applicant.id)
    end
    return scores
  end
  
  def get_applicant_to_4d(applicant)
    cs = {}
    cs["citizen_stage.jobstageid"] = self.jobstage_id
    cs["citizen_stage.score"] = applicant.weighted
    cs["application_data.answers"] = applicant.answers.gsub(/[wcs]\d{4}/,"")
    cs["applicant_id"] = applicant.id
    return cs
    
  end
  
  def process_selection(params)
    ids = params[:applicant][:id].collect {|i| i.to_i}
    applicants = Applicant.where(:id => ids)
    if params[:applicant][:selection] == "Selected"
      result = process_selected(applicants,params[:current_user_id])
      
    elsif params[:applicant][:selection] == "Profile"
      result = print_profiles(applicants)
    else
      result = change_status(applicants, params[:applicant][:selection])
    end
    return result
  end
  
  # the following methods are for conversion only. Not sure they can be resued after conversion.

    def create_assessment
      hash = ActiveSupport::JSON.decode(self.assessment_json)
      seq = 0
      hash.each do |key,area|
        seq += 1
        assessment_name =  "Job.#{self.job_id}"
        assessment_cat = "application.#{key}"
        assessment = Assessment.where(:name => assessment_name, :category => assessment_cat).first
        if !assessment.nil?
          next
        end
        assmnt = Assessment.new
        assmnt[:name] = "Job.#{self.job_id}"
        assmnt[:description] = self.project_name
        assmnt[:status] = "Imported"
        assmnt[:category] = "application.#{key}"
        assmnt[:xml_key] = key == "experience" ? "wh" : key[0..1]
        assmnt.save
        self.create_assessor(assmnt.id,seq)
        p assmnt[:xml_key]
        area.each do |qkey,question|
          ques = Question.new
          ques.assessment_id = assmnt.id
          ques.sequence = qkey.gsub(/[^0-9]/,"").to_i
          ques.shortname = question["name"][0..19]
          ques.question = question["text"]
          ques.answer_type = question["type"].downcase.include?("radio") ? "Radio" : question["type"]
          ques.display_type = question["display"].downcase.include?("line") ? "Inline" : "List"
          ques.weight = question["weight"]
          ques.critical = question["critical"]
          ques.minimum_value = question["min"]
          case question["score"].downcase
          when "sum"
            scorem = %w{checkbox select-multiple}.include?(ques.answer_type.downcase ) ? "Sum" : "Value"

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
          question["answers"].each do |akey,answer|
            ans = Answer.new
            ans.question_id = ques.id
            ans.sequence = answer["id"].to_i
            ans.shortname = answer["name"][0..19]
            ans.answer = answer["text"]
            ans.value = answer["value"].to_i
            ans.requires_other = !answer["other"].blank?
            ans.other_question = answer["other"]
            ans.xml_key = ques.xml_key + "_#{answer["id"]}"
            ans.save
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
      assessor.assessment_id = assessment_id
      assessor.sequence = seq
      assessor.assessed_model = "Applicant"
      assessor.status = "New"
      assessor.repeating = false
      assessor.save
    end
  
  
  
  protected
  
  def change_status(applicants,status)
    applicants.each do |applicant|
      applicant.status = status
      applicant.status_date = Date.today
      applicant.save
    end
    return "Status changed to #{status}"
  end
  
  def print_profiles(applicants)
    return "download pdf to ???"
  end
  
  def process_selected(applicants,current_user_id)
    #process then
    selected = []
    applicants.each do |applicant|
      cs_ad = get_applicant_to_4d(applicant)
      citizen = applicant.citizen_to_4d 
      selected << {"citizen" => citizen, "cs_ad" => cs_ad}
    end
    change_status(applicants,"Selected")
    selected_hash = {"jobstageid" => self.jobstage_id, "selected" => selected}
    export = Export.new
    export.token =  Devise.friendly_token
    export.user_id = current_user_id
    export.status = "New"
    export.sent = Time.now
    export.request = selected_hash.to_json
    export.save
    result =  %x[curl --form-string  'fdata=#{""}' 'http://192.211.32.248:8010/ws.ruok']
    if result.include?("Yes")
      result =  %x[curl --form-string  'fdata=#{""}' 'http://192.211.32.248:8010/ws.gotwork']
    end
    return "Applicants status change to selected. Export scheduled #{result}"
  end
  
  
end

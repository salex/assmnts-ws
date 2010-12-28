
class Applicant < ActiveRecord::Base
  belongs_to :stage
  belongs_to :user
  has_many :scores, :as => :assessed, :dependent => :destroy
  
  def self.last_post_to_new_post(applicant_id,assessment)
    applicant = Applicant.find(applicant_id)
    last_assessor = applicant.stage.assessors.joins(:assessment).where("assessments.category" => assessment.category).first
    return nil if last_assessor.nil?
    score = last_assessor.scores.where(:assessed_id => applicant.id).last
    return nil if score.nil?
    answers = Answer.select("answers.id").select('answers.xml_key').joins(:question => :assessment).where("questions.id = answers.question_id AND assessments.id = #{assessment.id}")
    questions = Question.select("questions.id").select('questions.xml_key').joins(:assessment).where("questions.assessment_id = #{assessment.id}")
    last_answers = Answer.select("answers.id").select('answers.xml_key').joins(:question => :assessment).where("questions.id = answers.question_id AND assessments.id = #{last_assessor.assessment_id}")
    last_questions = Question.select(["questions.id","questions.xml_key","questions.answer_type"]).joins(:assessment).where("questions.assessment_id = #{last_assessor.assessment_id}")
    ans_ids = answers.map(&:id)
    ans_xml = answers.map(&:xml_key)
    ques_ids = questions.map(&:id)
    ques_xml = questions.map(&:xml_key)
    lans_ids = last_answers.map(&:id)
    lans_xml = last_answers.map(&:xml_key)
    lques_ids = last_questions.map(&:id)
    lques_xml = last_questions.map(&:xml_key)
    lques_ans_type = last_questions.map(&:answer_type)
    
    post = ActiveSupport::JSON.decode(score.score_object)
    new_answers = {}
    answers_other = {}
    all_answers = []
    post["answers"].each do |ques,ans_array|
      lques_pos = lques_ids.index(ques.to_i)
      lqxml = lques_xml[lques_pos]
      ques_pos = ques_xml.index(lqxml)
      ques_id = ques_ids[ques_pos].to_s
      ans_type = lques_ans_type[lques_pos]
      new_answers[ques_id.to_s] = []
      isText =  !(ans_type =~ /text/i).nil?
      astep = isText ? 2 : 1
      0.step( ans_array.length - 1, astep) {|i|
        ans_id = ans_array[i].to_i
        lans_pos = lans_ids.index(ans_id)
        laxml = lans_xml[lans_pos]
        ans_pos = ans_xml.index(laxml)
        new_ans_id = ans_ids[ans_pos].to_s
        all_answers << ans_ids[ans_pos]
        new_answers[ques_id.to_s] << new_ans_id
        if isText 
          new_answers[ques_id.to_s] <<  ans_array[i + 1]
        end
      }
    end
    post["answers_other"].each do |other_ans,other_ans_text|
      lans_pos = lans_ids.index(other_ans.to_i)
      laxml = lans_xml[lans_pos]
      ans_pos = ans_xml.index(laxml)
      ans_id = ans_ids[ans_pos].to_s
      answers_other[ans_id] = other_ans_text
    end
    new_post = {"answers" => new_answers, "answers_other" => answers_other, "all_answers" => all_answers}
  end
  
  

  def application_reviewed?
    not_reviewed = %w{incomplete completed failed}.include?(self.status.downcase)
    return !not_reviewed
  end
  
  def make_score_summary
    summary = ""
    scores = self.scores
    scores.each do |score|
      so = score.score_object
      cat_start = so.index('"category"')
      cat_end = so.index('"max_raw"')
      cat = so.slice(cat_start..cat_end)
      score_start =  so.index('"score_weighted"')
      score_end = score_start + 22
      dascore = so.slice(score_start..score_end)
      if cat.include?("experience")
        keys_start = 1 
        keys_end = so.index('"all_answers"') - 1
        keys = so.slice(keys_start..keys_end).gsub(/"\d+"/,"")
        keys.gsub!(/,,/,",")
        keyarray = keys.split("],")
        keys = keyarray.join("],\n\t")
        dascore = ""
      else
        keys_start = so.index('"all_keys"') 
        keys_end = so.index('"answers_other"')  - 1
        keys = so.slice(keys_start..keys_end)
        if keys.length > 100
          pos = keys.index(",",100)
          keys = keys.slice(0..pos)+"\n\t" + keys.slice((pos + 1)..-1)
        end
      end
      score_start =  so.index('"score_weighted"')
      score_end = score_start + 22
      tmp = cat+"\n\t"+keys+"\n\t"+ dascore
      #summary << so.slice((so.index("total_raw") - 1)..-1)+"\n\n"
      summary << tmp.gsub(/"/,"") + "\n\n"
    end
    summary
  end
  
  def update_4d
    citizen_update = {"citizen" => citizen}
    fdata = citizen_update.to_json
    citizen =  %x[curl --form-string  'fdata=#{fdata}' 'http://localhost:8080/ws.citizen.update4d']
    if citizen[0..0] == "{"
      citizen = ActiveSupport::JSON.decode(citizen)
    else
      citizen = {"error" => citizen, "fdata" => fdata}
    end
    #TODO need to evaluate at some placess if success
    return citizen
		
  end
  
  def citizen_to_4d
    user = self.user
    if user.citizen_id.nil? || user.citizen_id == 0
      action = "create"
    else
      action = "update"
    end
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
    citizen_update = citizen
    return citizen_update
		
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
    self.answers = ""
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
      #answers << score_params[:answers] 
      self.answers << scored["all_keys"].join 
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
      #self.answers = answers.gsub("||","|")
      self.save
      
    end
  end
  
  def conv_4d_scores(assessor_hash = nil)
    if assessor_hash
      aids = assessor_hash[:aids]
      ans_ids = assessor_hash[:ans_ids]
      ans_xml = assessor_hash[:ans_xml]
      ques_ids = assessor_hash[:ques_ids]
      ques_xml = assessor_hash[:ques_xml]
      categories = assessor_hash[:categories]
      stage = self.stage
    else
      stage = self.stage
      aids = stage.assessors.select(:assessment_id).map(&:assessment_id)
      ans_ids = []
      ans_xml = []
      ques_ids = []
      ques_xml = []
      categories = {}
      aids.each do |aid|
        assmnt = Assessment.find(aid)
        categories[assmnt.category] = aid
        ans = Answer.select("answers.id").select('answers.xml_key').joins(:question => :assessment).where("questions.id = answers.question_id AND assessments.id = #{aid}")
        ques = Question.select("questions.id").select('questions.xml_key').joins(:assessment).where("questions.assessment_id = #{aid}")
        ans_ids << ans.map(&:id)
        ans_xml << ans.map(&:xml_key)
        ques_ids << ques.map(&:id)
        ques_xml << ques.map(&:xml_key)
      end
      ans_ids = ans_ids.flatten
      ans_xml = ans_xml.flatten
      ques_ids = ques_ids.flatten
      ques_xml = ques_xml.flatten
    end
    fdata = {"jobstageid" => stage.jobstage_id, "citizenid" => self.user.citizen_id}.to_json
    
    score =  %x[curl --form-string  'fdata=#{fdata}' 'http://localhost:8080/ws.jobstage.conv_score']
    if score.include?("Error")
      puts "bad score json"
      return false
    end 
    ans_xml.each_index do |i|
     score.gsub!(ans_xml[i], ans_ids[i].to_s)
    end
    ques_xml.each_index do |i|
      score.gsub!(ques_xml[i], ques_ids[i].to_s)
    end
    score_hash = ActiveSupport::JSON.decode(score)
    aids.each do |aid|
      assessor = stage.assessors.where(:assessment_id => aid).first
      test_score = Score.where(:assessor_id => assessor.id, :assessed_id => self.id).first
      if test_score.nil?
        assessment = assessor.assessment
        area = score_hash["score"][assessment.category]
        post = {"post.answer" => area["answers"], "post.answer_other" => area["answers_other"]}
        scored = assessment.scoreAssessment(post)
        score_params = {}
        score_params[:assessor_id] = assessor.id
        score_params[:assessed_type] = "Applicant"
        score_params[:assessed_id] = self.id
        score_params[:assessing_type] = "Stage"
        score_params[:assessing_id] = stage.id
        score_params[:score_object] = scored.to_json
        score_params[:score] = scored["score_raw"]
        score_params[:score_weighted] = scored["score_weighted"]
        score_params[:answers]  = "|" + scored["all_answers"].join("|") + "|"
        s = Score.create(score_params)
      end
    end
    #self.score =  score_params[:score]
    self.status = self.status.gsub("conv.","")

    self.rescore
    return true
    
  end
  
  
  
end

class WsController < ApplicationController
  #load_and_authorize_resource
  def get_xml_assmnt
    assmnt =  %x[curl --form-string  'fdata=#{params[:id]}' 'http://localhost:8080/ws.jobstage.get_xml_assmnt']
    hash = ActiveSupport::JSON.decode(assmnt)
    
    render :text => "<textarea>#{assmnt}</textarea>", :layout => true
  end
  
  def get_stages
    stages =  %x[curl --form-string  'fdata=#{params[:id]}' 'http://localhost:8080/ws.jobstage.get_stages']
    hash = ActiveSupport::JSON.decode(stages)
    hash.each do |key,stage|
      ns = Stage.create(stage)
    end
    render :text => "<textarea>#{stages}</textarea>", :layout => true
    
  end
  
  def conv_score
    fdata = {"jobstageid" => params[:id], "citizenid" => params[:citizen_id]}.to_json
    score =  %x[curl --form-string  'fdata=#{fdata}' 'http://localhost:8080/ws.jobstage.conv_score']
    
    render :text => "<textarea>#{score}</textarea>", :layout => true
  end
  
  def update_4d
    applicant = Applicant.find(params[:id])
    result = applicant.update_4d
    if result["result"]["result"] == "success"
      redirect_to stage_path(applicant.stage_id), :notice => "Citizen has been updated in 4D"
    else
      redirect_to stage_path(applicant.stage_id), :error => "Citizen has been updated in 4D, error #{result.inspect}"
    end
  end
  
  def test
    # generic test get test routine, pass id and append params in query string  /ws/:id/test?x=y;y=x
    test_import
    #render :text => params.inspect, :layout => true
    
  end
  
  def test_scores
    stage = Stage.where(:id => params[:id]).first
    aids = stage.assessors.select(:assessment_id).map(&:assessment_id)
    applicants = stage.stage_applicants({:filter => true,:status => "conv."})
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
    
    
    applicants.each do |applicant|
      fdata = {"jobstageid" => stage.jobstage_id, "citizenid" => applicant.user.citizen_id}.to_json
      score =  %x[curl --form-string  'fdata=#{fdata}' 'http://localhost:8080/ws.jobstage.conv_score']
      if score[0..0] != "{"
        puts "bad score json"
        next
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
        assessment = assessor.assessment
        area = score_hash["score"][assessment.category]
        post = {"post.answer" => area["answers"], "post.answer_other" => area["answers_other"]}
        scored = assessment.scoreAssessment(post)
        score_params = {}
        score_params[:assessor_id] = assessor.id
        score_params[:assessed_type] = "Applicant"
        score_params[:assessed_id] = applicant.id
        score_params[:assessing_type] = "Stage"
        score_params[:assessing_id] = stage.id
        score_params[:score_object] = scored.to_json
        score_params[:score] = scored["score_raw"]
        score_params[:score_weighted] = scored["score_weighted"]
        score_params[:answers]  = "|" + scored["all_answers"].join("|") + "|"
        s = Score.create(score_params)
      end
      #applicant.score =  score_params[:score]
      applicant.status = applicant.status.gsub("conv.","")
      applicant.save
      
      #need a summary method
    end
    render :text => "I be thruuuu", :layout => true
  end
  
  def test_import
    jstage ='{"jobstage":{"stage":{"jobstage_id":1852,"job_id":1484,"job_title":"Customer Service Representati","project_id":6367909,"project_name":"RYLA 2009","stage_name":"Application"},
    "user":{"106243":{"adid":105536,"citizen":{"address":"1416 Center Street","birth_dd":"11","birth_mm":"05","citizen_id":106243,"city":"Mobile","email":"bernice1416@yahoo.com","name_first":"Bernice","name_last":"Jones","name_mi":"C","phone_primary":"2514330413","phone_secondary":"2514016081","state":"AL","zip":"36604"},
    "date.completed":"May 12, 2009","date.dts":"20090512050000","email":"bernice1416@yahoo.com","key":"email","login":"2514330413.0511.BJ","password":"bernice1416@yahoo.com","score":82.03,"status":"conv.Progressed"},
    "108179":{"adid":105011,"citizen":{"address":"P.o Box 573","birth_dd":"21","birth_mm":"11","citizen_id":108179,"city":"Sheffield","email":"JAISMIMI@YAHOO.COM","name_first":"Millie","name_last":"Weakley","name_mi":"B","phone_primary":"2563899421","phone_secondary":"2563837992","state":"AL","zip":"35660"},
    "date.completed":"May 7, 2009","date.dts":"20090507050000","email":"JAISMIMI@YAHOO.COM","key":"email","login":"milliew0000","password":"2567601137","score":80.27,"status":"conv.Progressed"},
    "110975":{"adid":105850,"citizen":{"address":"1463 Athey Rd","birth_dd":"06","birth_mm":"10","citizen_id":110975,"city":"Mobile","email":"Parome11@yahoo.com","name_first":"Parome","name_last":"McGill","name_mi":"M","phone_primary":"2513411269","phone_secondary":"2514638138","state":"AL","zip":"36608"},
    "date.completed":"May 14, 2009","date.dts":"20090514050000","email":"Parome11@yahoo.com","key":"email","login":"2513411269.1006.PM","password":"Parome11@yahoo.com","score":71.08,"status":"conv.Progressed"},
    "111214":{"adid":106880,"citizen":{"address":"232 Brent Street","birth_dd":"21","birth_mm":"01","citizen_id":111214,"city":"Hamilton","email":"elsworm@centurytel.net","name_first":"Clement","name_last":"Sink","name_mi":"","phone_primary":"2059529889","phone_secondary":"","state":"AL","zip":"35570"},
    "date.completed":"May 26, 2009","date.dts":"20090526050000","email":"elsworm@centurytel.net","key":"email","login":"bigg4wheeler","password":"union1990","score":69.32,"status":"conv.Progressed"},
    "112157":{"adid":104604,"citizen":{"address":"1566 Eslava Street","birth_dd":"19","birth_mm":"03","citizen_id":112157,"city":"Mobile","email":"allenmaurice_24@yahoo.com","name_first":"Maurice","name_last":"Allen","name_mi":"V","phone_primary":"2517762949","phone_secondary":"2514712246","state":"AL","zip":"36604"},
    "date.completed":"May 4, 2009","date.dts":"20090504050000","email":"allenmaurice_24@yahoo.com","key":"login","login":"2517762949.0319.MA","password":"allenmaurice_24@yahoo.com","score":74.58,"status":"conv.Progressed"}}}}'
    jstage = ActiveSupport::JSON.decode(jstage)
    stage = jstage["jobstage"]["stage"]
    users = jstage["jobstage"]["user"]
    stuff = ""
    users.each do |key,user|
      
      citizen = user["citizen"]
      if user["key"] == 'login'
        citizen["email"] = user["login"] + "@jobs.aidt.edu"
      elsif user["key"] == 'email'
        citizen["email"] = user["email"] 
      else
        stuff <<  citizen["email"] +"-"+ user["key"] + " Not imported\n"
        next
      end
      citizen["login"] = user["login"]
      citizen["password"] = user["password"]
      citizen["password_confirmation"] = user["password"]
      u = User.find_for_database_authentication({:email => citizen["email"], :login => citizen["login"]})
      if !u.nil?
        stuff <<  citizen["email"] + "Already in db \n"
        next
      end
      nu = User.new(citizen)
      if nu.valid?
        nu.save
        nu.confirm!
        nu.save
      else
        stuff << citizen["email"] + "invalid user #{nu.errors}"
        next
      end
      applicant = {}
      datedts = user["date.dts"]
      applicant["status_date"] = datedts[0..3]+"-"+datedts[4..5]+"-"+datedts[6..7]
      applicant["score"] = user["score"]
      applicant["status"] = user["status"]
      applicant["user_id"] = nu.id
      applicant["stage_id"] = 11
      na = Applicant.create(applicant)
      
    end
    
    #render :text => "<textarea>#{stuff}</textarea>", :layout => true
    render :text => stuff, :layout => true
    
  end
  
end
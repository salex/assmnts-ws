# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

def json_parse(json)
  return ActiveSupport::JSON.decode(json)
end

require File.expand_path('../conversion/stage', __FILE__)

# archive records using json
=begin
filepath = Rails.root.join("db","people.json")
json = Person.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote people records"

filepath = Rails.root.join("db","assessments.json")
json = Assessment.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote assessments records"

filepath = Rails.root.join("db","questions.json")
json = Question.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote questions records"

filepath = Rails.root.join("db","answers.json")
json = Answer.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote answers records"

filepath = Rails.root.join("db","assessors.json")
json = Assessor.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote assessors records"

filepath = Rails.root.join("db","candidates.json")
json = Candidate.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote candidates records"

filepath = Rails.root.join("db","scores.json")
json = Score.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote scores records"

filepath = Rails.root.join("db","stages.json")
json = Stage.all.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote stages records"
=end

=begin
filepath = Rails.root.join("db","people.json")
json = File.read(filepath)
people = json_parse(json)
people.each {|i| 
  person = Person.new(i["person"])
  person.id = i["person"]["id"]
  person.save
}
puts "Wrote people records"

filepath = Rails.root.join("db","assessors.json")
json = File.read(filepath)
assessors = json_parse(json)
assessors.each {|i| 
  assessor = Assessor.new(i["assessor"])
  assessor.id = i["assessor"]["id"]
  assessor.save
}
puts "Wrote assessor records"

filepath = Rails.root.join("db","candidates.json")
json = File.read(filepath)
candidates = json_parse(json)
candidates.each {|i| 
  candidate = Candidate.new(i["candidate"])
  candidate.id = i["candidate"]["id"]
  candidate.save
}
puts "Wrote candidate records"

filepath = Rails.root.join("db","scores.json")
json = File.read(filepath)
scores = json_parse(json)
scores.each {|i| 
  score = Score.new(i["score"])
  score.id = i["score"]["id"]
  score.save
}
puts "Wrote scores records"

filepath = Rails.root.join("db","stages.json")
json = File.read(filepath)
stages = json_parse(json)
stages.each {|i| 
  stage = Stage.new(i["stage"])
  stage.id = i["stage"]["id"]
  stage.save
}
puts "Wrote stage records"


filepath = Rails.root.join("db","assessments.json")
json = File.read(filepath)
assessments = json_parse(json)
assessments.each {|i| 
  assessment = Assessment.new(i["assessment"])
  assessment.id = i["assessment"]["id"]
  assessment.save
}
puts "Wrote assessment records"

filepath = Rails.root.join("db","stage18521.json")
json = File.read(filepath)
conversion = json_parse(json)

=end

=begin
filepath = Rails.root.join("db","questions.json")
json = File.read(filepath)
questions = json_parse(json)
questions.each {|i| 
  question = Question.new(i["question"])
  question.id = i["question"]["id"]
  question.save
}
puts "Wrote question records"

filepath = Rails.root.join("db","answers.json")
json = File.read(filepath)
answers = json_parse(json)
answers.each {|i| 
  answer = Answer.new(i["answer"])
  answer.id = i["answer"]["id"]
  answer.save
}
puts "Wrote answer records"
=end

=begin
filepath = Rails.root.join("db","stage1852.json")
json = File.read(filepath)
jstage = json_parse(json)
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
  puts citizen["email"] + " OK"
end

puts stuff

=end

=begin
stage = Stage.where(:id => 11).first
aids = stage.assessors.select(:assessment_id).map(&:assessment_id)
applicants = stage.applicants.all
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

cnt = 0

applicants.each do |applicant|
  cnt += 1
  fdata = {"jobstageid" => stage.jobstage_id, "citizenid" => applicant.user.citizen_id}.to_json
  puts fdata+cnt.to_s
  score =  %x[curl --form-string  'fdata=#{fdata}' 'http://localhost:8080/ws.jobstage.conv_score']
  if score[0..0] != "{"
    puts "bad score json"
    next
  end 
  if !score["result"].nil? 
    puts score.inspect
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
    test_score = Score.where(:assessor_id => assessor.id, :assessed_id => applicant.id).first
    if test_score.nil?
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
  end
  #applicant.score =  score_params[:score]
  applicant.status = applicant.status.gsub("conv.","")
  applicant.rescore
  
  #need a summary method
end
=end
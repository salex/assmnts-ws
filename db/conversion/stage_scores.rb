ts = Time.now

result =  %x[curl --form-string  'fdata=#{""}' 'http://192.211.32.248:8010/ws.ruok']
if result.include?("Yes")
  stages = Stage.where(:id => [58])
  
else
  puts "Stage Scores not complete because 4d is down"
  stages = nil
end


stages.each do |stage|
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
  assessor_hash = {:aids => aids, :ans_ids => ans_ids, :ans_xml => ans_xml, :ques_ids => ques_ids, :ques_xml => ques_xml, :categories => categories}
  applicants = stage.applicants
  stuff = ""
  applicants.each do |applicant|
    result = applicant.conv_4d_scores(assessor_hash)
    if !result
      stuff << "applicant #{applicant.id} didn't have a good score"
    end
  end
end

puts "Started #{ts} ended #{Time.now}"

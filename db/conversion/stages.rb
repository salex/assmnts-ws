result =  a4d_fcurl("","ws.ruok")
if result.include?("Yes")
  result =  a4d_fcurl("","ws.getstages")
end

stages = json_parse(result)
ActiveRecord::Base.connection.reset_pk_sequence!('assessments')
ActiveRecord::Base.connection.reset_pk_sequence!('questions')
ActiveRecord::Base.connection.reset_pk_sequence!('answers')

stages.each do |stage|
  puts stage["job"].inspect
  ns = Stage.new(stage["job"])
  ns.assessment_json =
  #assmnt = %x[curl  'http://192.211.32.248:8080/ws.getot_assmnt?jobstageid=#{stage["job"]["jobstage_id"]}']
  assmnt = a4d_qcurl("ws.getot_assmnt?jobstageid=#{stage["job"]["jobstage_id"]}")
  ns.assessment_json = assmnt
  ns.save
  ns.create_assessment
end

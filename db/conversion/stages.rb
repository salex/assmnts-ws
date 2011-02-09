result =  %x[curl --form-string  'fdata=#{""}' 'http://192.211.32.248:8010/ws.ruok']
if result.include?("Yes")
  result =  %x[curl --form-string  'fdata=#{""}' 'http://192.211.32.248:8010/ws.getstages']
end

stages = json_parse(result)

stages.each do |stage|
  puts stage["job"].inspect
  ns = Stage.new(stage["job"])
  ns.assessment_json =
  assmnt = %x[curl  'http://192.211.32.248:8010/ws.getot_assmnt?jobstageid=#{stage["job"]["jobstage_id"]}']
  ns.assessment_json = assmnt
  ns.save
  ns.create_assessment
end

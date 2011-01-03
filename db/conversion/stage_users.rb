# get the stages
# query 4d for citizen count
# import users/applicants in chunks of 500
#http://localhost:8080/ws.getusercount?jobstageid=1852
ts = Time.now
def make_applicant_user(jobstage,stage) 
  stuff = "" 
  users = jobstage["jobstage"]["user"]
  users.each do |key,user|
    #users = jstage["jobstage"]["user"]
    
    citizen = user["citizen"]
    if user["key"] == 'login'
      citizen["email"] = user["login"] + "@jobs.aidt.edu"
    elsif user["key"] == 'email'
      citizen["email"] = user["email"].gsub(/,/,".").gsub(/ /,"")
    else
      stuff <<  citizen["email"] +"-"+ user["key"] + " cid #{citizen["citizen_id"]} Not imported\n"
      next
    end
    if user["password"].length < 6
      user["password"] += ".short"
    end
    citizen["login"] = user["login"]
    citizen["password"] = user["password"]
    citizen["password_confirmation"] = user["password"]
    u = User.find_for_database_authentication({:email => citizen["email"], :login => citizen["login"]})
    if !u.nil?
      stuff <<  citizen["email"] + "Already in db \n"
      nu = u
    else
      nu = User.new(citizen)
      if nu.valid?
        nu.save
        nu.confirm!
        nu.save
      else
        stuff << citizen["email"] + "cid #{citizen["citizen_id"]}  invalid user #{nu.errors}\n"
        next 
      end
    end
    tapp = Applicant.where(:user_id => nu.id, :stage_id =>  stage.id).count
    if tapp > 0
      stuff << citizen["email"] + "cid #{citizen["citizen_id"]}  Applicant already in stage\n"
    end
    applicant = {}
    datedts = user["date.dts"]
    applicant["status_date"] = datedts[0..3]+"-"+datedts[4..5]+"-"+datedts[6..7]
    applicant["weighted"] = user["score"]
    applicant["status"] = user["status"]
    applicant["applied_date"] = user["applied_date"]
    applicant["user_id"] = nu.id
    applicant["stage_id"] = stage.id
    na = Applicant.create(applicant)
    #puts citizen["email"] + " OK"
  end
  puts stuff
end

result =  %x[curl --form-string  'fdata=#{""}' 'http://localhost:8080/ws.ruok']
if !result.include?("Yes")
  raise::Active4DisDown
  
end

stages = Stage.where(:id => [10])

stages.each do |stage|
  users =  %x[curl http://localhost:8080/ws.getusercount?jobstageid=#{stage.jobstage_id}]
  webusers = users.to_i
  puts "webusers #{webusers} jobstage #{stage.jobstage_id}"
  1.step(webusers,500) {|start|
    curl = "curl 'http://localhost:8080/ws.get_users?jobstageid=#{stage.jobstage_id}&start=#{start}'"
    puts "webusers #{webusers} jobstage #{stage.jobstage_id} start #{start} curl #{curl}"
    batch = json_parse(%x[#{curl}])
    make_applicant_user(batch,stage)
    
    #call 4d
    #and call below code to create users/appliicants
    }
end
puts "Started #{ts} ended #{Time.now}"

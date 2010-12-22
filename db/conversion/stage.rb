filepath = Rails.root.join("db/conversion","stage1840.json")
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
      stuff << citizen["email"] + "invalid user #{nu.errors}\n"
      next
    end
  end
  applicant = {}
  datedts = user["date.dts"]
  applicant["status_date"] = datedts[0..3]+"-"+datedts[4..5]+"-"+datedts[6..7]
  applicant["weighted"] = user["score"]
  applicant["status"] = user["status"]
  applicant["user_id"] = nu.id
  applicant["stage_id"] = 10
  na = Applicant.create(applicant)
  puts citizen["email"] + " OK"
end
puts stuff

=begin
if ($wuris > 1)
pcutiepy69@aol.comAlready in db 
nfrober@comcast.net-duplicate email  duplicate login Not imported
deedee1994@@hotmail.cominvalid user {:email=>["is invalid"]}
tom.mitchell60@gmailinvalid user {:email=>["is invalid"]}
noemail@aidt.edu-huh! Not imported
janie`f0107@jobs.aidt.eduinvalid user {:email=>["is invalid"]}
bheiken200invalid user {:email=>["is invalid"]}
traceysteadman@yahoo.com-duplicate email  duplicate login Not imported
pmartin@andycable.com-duplicate email  duplicate login Not imported
shahmirria@comcast.netAlready in db 
www.need.to.workinvalid user {:email=>["is invalid"]}
heather_ byrd_05@yahoo.cominvalid user {:email=>["is invalid"]}
fevans1@bellsouth.netAlready in db 
jmaefowlerinvalid user {:email=>["is invalid"]}
kawanajohnson3@yahoo.com-duplicate email  duplicate login Not imported
diannenorwood@yahoo,.cominvalid user {:email=>["is invalid"]}
bobbie jop0305@jobs.aidt.eduinvalid user {:email=>["is invalid"]}
s michellec1024@jobs.aidt.eduinvalid user {:email=>["is invalid"]}
lil_double_o@opp cabletvinvalid user {:email=>["is invalid"]}
=end

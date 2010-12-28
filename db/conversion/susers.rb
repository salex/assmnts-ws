json = '[{"user":{"address":"6045 Meridain lane","birth_dd":"17","birth_mm":"10","citizen_id":9937,"city":"Gadsden","email":"salex@mac.com","name_first":"Steve","name_last":"Alex","name_mi":"V","phone_primary":"334","roles":null,"state":"AL","user_type":"admin","zip":"35901"}},{"user":{"address":"shorter","birth_dd":"24","birth_mm":"7","citizen_id":null,"city":"shorter","email":"sfoster@aidt.edu","name_first":"Susan","name_last":"Foster","name_mi":"","phone_primary":"334","roles":"","state":"al","user_type":"admin","zip":"34455"}},{"user":{"address":null,"birth_dd":null,"birth_mm":null,"citizen_id":null,"city":null,"email":"joesmho@smho.com","name_first":"Joe","name_last":"Smho","name_mi":"","phone_primary":null,"roles":"6367909|6367409","state":null,"user_type":"company","zip":null}},{"user":{"address":"15 Technology Court","birth_dd":"24","birth_mm":"9","citizen_id":113421,"city":"Montgomery","email":"rbush@aidt.edu","name_first":"Rusty","name_last":"Bush","name_mi":"","phone_primary":"334-280-4464","roles":"","state":"AL","user_type":"admin","zip":"36116"}},{"user":{"address":null,"birth_dd":null,"birth_mm":null,"citizen_id":null,"city":null,"email":"jproject@jobs.aidt.edu","name_first":"Joe","name_last":"Project","name_mi":"","phone_primary":null,"roles":"","state":null,"user_type":"project","zip":null}},{"user":{"address":null,"birth_dd":null,"birth_mm":null,"citizen_id":null,"city":null,"email":"dhall@aidt.edu","name_first":"Doug","name_last":"Hall","name_mi":"","phone_primary":null,"roles":"","state":null,"user_type":"admin","zip":null}},{"user":{"address":null,"birth_dd":null,"birth_mm":null,"citizen_id":null,"city":null,"email":"jadmin@jobs.aidt.edu","name_first":"Joe","name_last":"Admin","name_mi":"","phone_primary":null,"roles":"","state":null,"user_type":"admin","zip":null}}]'
users = json_parse(json)
users.each do |hash|
  user = hash["user"]
  
  user[:password] = "please"
  
  user[:password_confirmation] = "please"
  
  nu = User.new(user)
  puts nu.inspect
  nu.save
  nu.confirm!
  nu.save
  
end

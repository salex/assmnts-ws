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

answers = Answer.joins(:question => :assessment).where("assessments.status" => "Master")
questions = Question.joins(:assessment).where("assessments.status" => "Master")
assessments = Assessment.where("assessments.status" => "Master")

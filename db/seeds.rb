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
=end

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



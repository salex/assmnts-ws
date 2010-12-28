# This is the second step in the conversion.
#   what was exported from the development master assessments is imported


filepath = Rails.root.join("db/conversion","assessments.json")
json = File.read(filepath)
assessments = json_parse(json)
assessments.each {|i| 
  assessment = Assessment.new(i["assessment"])
  assessment.id = i["assessment"]["id"]
  assessment.save
}
puts "Wrote assessment records"

filepath = Rails.root.join("db/conversion","questions.json")
json = File.read(filepath)
questions = json_parse(json)
questions.each {|i| 
  question = Question.new(i["question"])
  question.id = i["question"]["id"]
  question.save
}
puts "Wrote question records"

filepath = Rails.root.join("db/conversion","answers.json")
json = File.read(filepath)
answers = json_parse(json)
answers.each {|i| 
  answer = Answer.new(i["answer"])
  answer.id = i["answer"]["id"]
  answer.save
}
puts "Wrote answer records"


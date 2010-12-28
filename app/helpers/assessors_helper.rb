module AssessorsHelper
  
  def answer_keys(assessment_id)
    assessment = Assessment.find(assessment_id)
    if assessment.category.include?("experience")
      return ""
    end
    html = "<h5>#{assessment.category}</h5>"
    questions = assessment.questions
    questions.each do |question|
      html << question_summary(question)
    end
    html.html_safe
  end
  
  def question_summary(question)
    
    html = "<div class=\"question box\">#{question.xml_key.gsub("_","").delete(question.xml_key.slice(1..1))} - #{question.question}"
    html << "<div class=\"answers\">"
    answers = question.answers
    answers.each do |answer|
      html << answer_summary(answer)
    end
    html << "<div class=\"f-clear\"></div></div></div>"
    html
  end
  
  def answer_summary(answer)
    key = answer.xml_key.gsub("_","").delete(answer.xml_key.slice(1..1))
    sel = "[<a class=\"l-and\" href=\"javascript:and_ans('#{key}');return(false);\"></a><a class=\"l-and1\" href=\"javascript:and_ans('#{key}');return(false);\"></a>
    
    :<a class=\"l-or\" href=\"javascript:or_ans('#{key}');return(false)\"></a><a class=\"l-or1\" href=\"javascript:or_ans('#{key}');return(false)\"></a>]"
    html = "<div class=\"f-left little-box\">#{sel} #{answer.shortname.blank? ? truncateText(answer.answer,30,"middle") : truncateText(answer.shortname,30,"middle") } - #{key}</div>"
  end
  
end

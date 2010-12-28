module ApplicantsHelper
  def showfield(label,content,other="")
    result = "<th>#{truncateText(label,22)}</th><td>#{content}#{("<br />"+other) if !other.blank?}</td></tr>".html_safe
  end
  def applicant_status_options(status)
    if status.nil?
      status = ""
    end
    types = {"--Change--" => "", "Dropped" => "Dropped", "Selected" => "Selected"}
    result = options_for_select(types,status.capitalize)
    return result.html_safe
  end
  def applicant_status_options_all(status)
    if status.nil?
      status = ""
    end
    types = {"--Default--" => "", "Dropped" => "Dropped", "Selected" => "Selected",
      "Failed" => "Failed", "Incomplete" => "Incomplete", "Hold" => "Hold", "Completed" => "Completed", "Withdrew" => "Withdrew","All" => "All"}
    result = options_for_select(types,status.capitalize)
    return result.html_safe
  end
  
  def show_question(question)
    ans = ""
    ans_array = @score_hash["answers"][question.id.to_s]
    isText =  !(question.answer_type =~ /text/i).nil?
    if isText
      0.step(ans_array.length-1,2) { |i|
        ans += "#{ans_array[i+1]}, "
      }
    else
      ans_array.each do |i|
        ansID = i.to_i
        ansIDX = @qa[:a_ids].index(ansID) 
        if ansIDX.blank?
          next
        end
        ansans = @qa[:answers][ansIDX][:shortname].blank? ? truncateText(@qa[:answers][ansIDX][:answer],20) : truncateText(@qa[:answers][ansIDX][:shortname],20)
        if @score_hash["answers_other"][i]
          ansOther = "{"+@score_hash["answers_other"][i]+"}"
        end
        ans += "#{ansans}#{ansOther} "
      end
    end
    return showfield(question.shortname.blank? ? question.question : question.shortname,ans)
  end
  
  def show_answer(answer)
    if @score.answers.include?("|#{answer.id.to_s}|")
      ansOther = ""
      if @score_hash["answers_other"][answer.id.to_s]
        ansOther = "{"+@score_hash["answers_other"][answer.id.to_s]+"}"
      end
      
      return showfield(answer.shortname.blank? ? answer.answer : answer.shortname,"&radic;#{ansOther}")
    else
      return showfield(answer.shortname.blank? ? answer.answer : answer.shortname,"")
    end
  end
  
  def show_answer_text(answer)
    if @score.answers.include?("|#{answer.id.to_s}|")
      ans_array = @score_hash["answers"][answer.question_id.to_s]
    
      ansidx = ans_array.index(answer.id.to_s)
      ans = ans_array[ansidx+1]
      return showfield(answer.shortname.blank? ? answer.answer : answer.shortname,ans)
    else
      return showfield(answer.shortname.blank? ? answer.answer : answer.shortname,"")
    end
  end
  
end

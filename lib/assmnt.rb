module Assmnt
  
  
  def status_options(status)
    if status.nil?
      status = ""
    end
    types = %W( #{""} New Active Locked Master)
    result = options_for_select(types,status.capitalize)
    return result.html_safe
  end
  
  def answer_type_options(answer_type)
    if answer_type.nil?
      answer_type = ""
    end
    types = %W( #{""} Radio Checkbox Select Select-multiple Text Textarea Textform Text_numeric Text_completion)
    result = options_for_select(types,answer_type.capitalize)
    return result.html_safe
  end
  
  def display_type_options(display_type)
    if display_type.nil?
      display_type = ""
    end
    types = %W(List Inline None)
    result = options_for_select(types,display_type.capitalize)
    return result.html_safe
  end
  
  def score_method_options(score_method)
    if score_method.nil?
      score_method = ""
    end
    types = %W( Value Sum Max None)
    result = options_for_select(types,score_method.capitalize)
    return result.html_safe
  end
  
  def computeMax(id)
    if id.nil?
      return false
    end
    assessment = Assessment.find(id)
    
    maxRaw = 0
    maxWeighted = 0
    
    for question in assessment.questions
      maxQues = 0
      sumQues = 0
      
      weight = question.weight.nil? ? 0 : question.weight.to_f
      ansType = question.answer_type.blank? ? "" : question.answer_type.downcase
      scoreMethod = question.score_method.blank? ? "value" : question.score_method.downcase
      isScored = ((scoreMethod.downcase != "none") ) # and (weight > 0)
      isText =  !(ansType =~ /text/i).nil?
      for answer in question.answers
        isTextScored =  !answer.answer_eval.blank? 
        value = answer.value.to_f
        if isScored
          if ((isText  and isTextScored) or (!isText ))
            if (value > maxQues)
              maxQues = value
            end if
            sumQues += value        
          end
        end
      end
      if ((scoreMethod == "sum")  and ((ansType == "checkbox") or (ansType == "select-multiple")))
        maxRaw += sumQues
        maxWeighted += (sumQues * weight)
      else
        maxRaw += maxQues
        maxWeighted += (maxQues * weight)
      end
    end
    assessment.max_raw = maxRaw
    assessment.max_weighted = maxWeighted
    assessment.save
    return true
  end
  
  def truncateText(text,length = 40, where = "end")
    if text.nil?
      return text
    end
    text_length = text.length
    if text_length <= length
      return text
    end
    if where.downcase == "end"
      return( text.first(length)+"&hellip;")
    elsif where.downcase == "begin"
      return( text.last(length)+"&hellip;")
    else
      return(text.first(length / 2)+"&hellip;"+ text.last(length / 2))
    end
  end
  
  def dumpPost(post,qa,obj = false,ids = false, css = nil)
    cclass = css ? css : "assmnt-list"
    html = "<div class=\"#{cclass}\" style=\"font-size:.8em\">"
    html << "<table><tr class=\"list-header\"><th style=\"width:130px\">Scores/(Fail)</th><th colspan=\"2\" class=\"center\">#{post["category"]}</th></tr>"
    html << "<tr class=\"list-header\"><th>rs*w=ws (F)</th><th>Question</th><th>Answer(s)</th></tr>\n"
    post["answers"].each {|key,value|
      value_display = ""
      key_i = key.to_i
      queIDX = qa[:q_ids].index(key_i)
      queID = qa[:q_ids][queIDX].to_s
      dropped = ""
      if post["failed"].include?(key_i)
        dropped = " <span style=\"color:red\">(F)</span>"
      end
      ques = qa[:questions][queIDX][:shortname].blank? ? truncateText(qa[:questions][queIDX][:question],30) : qa[:questions][queIDX][:shortname]
      ques = "[#{(key+":") if ids}#{ques}]"
      ansOther = ""
      isArray = value.kind_of? Array
      weight = qa[:questions][queIDX][:weight].nil? ? 0 :qa[:questions][queIDX][:weight]
      ansType = qa[:questions][queIDX][:answer_type].blank? ? "" : qa[:questions][queIDX][:answer_type].downcase
      isText =  !(ansType =~ /text/i).nil?
      if isText
        
        0.step(value.length-1,2) { |i|
          ansID = value[i].to_i
          ansText = value[i+1]
          ansIDX = qa[:a_ids].index(ansID) 
          
          if ansIDX.blank?
            next
          end
          ansans = qa[:answers][ansIDX][:shortname].blank? ? truncateText(qa[:answers][ansIDX][:answer],30) : qa[:answers][ansIDX][:shortname]
          if post["answers_other"][value[i]]
            ansOther = "{"+post["answers_other"][value[i]]+"}"
          end
          value_display += "[#{(value[i]+":") if ids}#{ansans}=>#{ansText}#{ansOther}] "
          
        }
      elsif isArray
        for i in 0..value.length-1
          ansID = value[i].to_i
          ansIDX = qa[:a_ids].index(ansID) 
          if ansIDX.blank?
            next
          end
          ansans = qa[:answers][ansIDX][:shortname].blank? ? truncateText(qa[:answers][ansIDX][:answer],20) : truncateText(qa[:answers][ansIDX][:shortname],20)
          if post["answers_other"][value[i]]
            ansOther = "{"+post["answers_other"][value[i]]+"}"
          end
          value_display += "[#{(value[i]+":") if ids}#{ansans}#{ansOther}] "
        end
      else
        ansID = value.to_i
        ansIDX = qa[:a_ids].index(ansID) 
        if ansIDX.blank?
          next
        end    
        ansans = qa[:answers][ansIDX][:shortname].blank? ? truncateText(qa[:answers][ansIDX][:answer],20) : truncateText(qa[:answers][ansIDX][:shortname],20)
        if post["answers_other"][value]
          ansOther = "{"+post["answers_other"][value]+"}"
        end
        
        value_display += "[#{value}:#{ansans}#{ansOther}] "
      end
      
      val = post["question_raw"][queID]
      valw = val * weight
      if val == 0
        val = "0.0"
      else
        val = val.to_s
      end
      score = val + " * "+ weight.to_s + " = "+ valw.to_s + dropped
      
      html << "<tr><td>#{score}</td><td>#{ques}</td><td>#{value_display}</td></tr>"
    }
    html << "</table>"
    if obj
      html << "<div class=\"actions\">"+post.inspect+"</div>"
    end
    html << "</div>"
    return html
  end
  
  def dumpSummary(post,qa,options = {})
    opt = {"class" => nil,"obj" => false, "twidth" => "p100"}.update(options.stringify_keys)

    cclass = opt["class"] ?  opt["class"] : "assmnt-list"
    html = "<div class=\"#{cclass}\" >"
    html << "<table class=\"#{opt["twidth"]}\"><tr class=\"#{cclass}-header\"><th colspan=\"2\" >#{post["category"]}</th>"
    html << "<th class=\"profile-score\">Scores/(Fail)</th></tr>"
    html << "<tr class=\"#{cclass}-header\"><th>Question</th><th>Answer(s)</th><th class=\"profile-score\">rs*w=ws (F)</th></tr>\n"
    post["answers"].each {|key,value|
      value_display = ""
      key_i = key.to_i
      queIDX = qa[:q_ids].index(key_i)
      queID = qa[:q_ids][queIDX].to_s
      dropped = ""
      if post["failed"].include?(key_i)
        dropped = " <span style=\"color:red\">(F)</span>"
      end
      ques = qa[:questions][queIDX][:shortname].blank? ? truncateText(qa[:questions][queIDX][:question],30) : qa[:questions][queIDX][:shortname]
      #ques = "[#{(key+":") if ids}#{ques}]"
      ansOther = ""
      weight = qa[:questions][queIDX][:weight].nil? ? 0 :qa[:questions][queIDX][:weight]
      ansType = qa[:questions][queIDX][:answer_type].blank? ? "" : qa[:questions][queIDX][:answer_type].downcase
      isText =  !(ansType =~ /text/i).nil?
      if isText

        0.step(value.length-1,2) { |i|
          ansID = value[i].to_i
          ansText = value[i+1]
          ansIDX = qa[:a_ids].index(ansID) 

          if ansIDX.blank?
            next
          end
          ansans = qa[:answers][ansIDX][:shortname].blank? ? truncateText(qa[:answers][ansIDX][:answer],30) : qa[:answers][ansIDX][:shortname]
          if post["answers_other"][value[i]]
            ansOther = "{"+post["answers_other"][value[i]]+"}"
          end
          value_display += "[#{ansans}=>#{ansText}#{ansOther}] "

        }
      else 
        for i in 0..value.length-1
          ansID = value[i].to_i
          ansIDX = qa[:a_ids].index(ansID) 
          if ansIDX.blank?
            next
          end
          ansans = qa[:answers][ansIDX][:shortname].blank? ? truncateText(qa[:answers][ansIDX][:answer],20) : truncateText(qa[:answers][ansIDX][:shortname],20)
          if post["answers_other"][value[i]]
            ansOther = "{"+post["answers_other"][value[i]]+"}"
          end
          value_display += "[#{ansans}#{ansOther}] "
        end
      end

      val = post["question_raw"][queID]
      valw = val * weight
      if val == 0
        val = "0.0"
      else
        val = val.to_s
      end
      score = val + " * "+ weight.to_s + " = "+ valw.to_s + dropped

      html << "<tr><td>#{ques}</td><td>#{value_display}</td><td class=\"profile-score\">#{score}</td></tr>"
    }
    html << "</table>"
    if opt["obj"]
      html << "<div class=\"actions\">"+post.inspect+"</div>"
    end
    html << "</div>"
    return html
  end
  
  def scoreChunk(ansText,chunk)
    partial = chunk.split("::")
    if partial.length == 2
      partialVal = partial[0].to_f
      chunk = partial[1]
    else
      partialVal = 1
    end
    if chunk[0..0] != "!" # is answer negated? first character = !, else not
      eq = true
    else
      eq = false
      chunk = chunk[1..-1]
    end  
    re = Regexp.new(chunk,true)
    ok = !( re =~ ansText).nil? # it is there or not
    if (ok and eq) or (!ok and !eq)
      score = partialVal
    else
      score = 0
    end
    return score, partialVal
  end

  def scoreText(ansValue,ansEval,ansText,ansType)
    ansValue = ansValue.to_f # in case big decimal or integer
    eq = true
    if (ansEval[0..0] == "!") and (ansEval.include?("&")) # is answer negated? first character = !, else not
      eq = false
      ansEval = ansEval[1..-1]
    end
    if ansType == "text_numeric"      
      between = ansEval.split("..")
      if between.length == 2
        ok = ((ansText.to_f >= between[0].to_f) and ( ansText.to_f <= between[1].to_f))
      else
        ok = ansText.to_f == ansEval.to_f
      end
      if ok
        val = ansValue
      else
        val = 0
      end
    else
      and_splits = ansEval.split("&")
      score = max = 0
      for chunk in and_splits
        partialScore, partialMax = scoreChunk(ansText,chunk)
        if partialMax > 0
          max += partialMax
        end
        score +=  partialScore
        #puts("ps #{partialScore} pm #{partialMax} sc #{score} mx #{max} eq #{eq}" )
      end
      if score > 0 and !eq
        val = 0
      else
        val = (ansValue) * (score/max)
      end
    end
    return val
  end
end

class String < Object
=begin 
      I got tired of trying to use gsub, reqexp, downcase, etc to see if 
      something was in a list of words. Maybe there is already something
      out there, but wrote my own
      in console (or put in lib)
      
      status = "progressed"
      status.in?("Dropped Completed Failed Progressed")
=end
  def in?(list,down=true)
    me =  down ? self.downcase : self
    list = list.downcase if down
    inarray = list.split
    return inarray.include?(me)
  end
end

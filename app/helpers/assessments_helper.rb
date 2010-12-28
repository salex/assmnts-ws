module AssessmentsHelper
  
  def format_question(question)
    result = "&curren; "+ question.question
    if !question.note.blank?
      result += " <i class=\"assmnt-annotate\">#{question.note}</i>"
    end
    return result
  end
  
  def getAnswerData(answer,ques_attr)
    ans = ""
    chkd = false
    othans = ""
    if (params["post"])
      #Answers from a previous application or session are in the Params collection - values are extracted
      #into the variables ans, chkd, and othans 
      ansID = answer.id.to_s
      ansIDv =  answer.id
      queID = answer.question_id.to_s
      if !params["post"]["all_answers"].index(answer.id).nil?
        chkd = true
        othans = params["post"]["answers_other"][ansID]
      end
      if(ques_attr[:isText])
        pos = params["post"]["answers"][queID].index(ansID)
        if !pos.nil?
          ans = params["post"]["answers"][queID][pos + 1]
        end
      end
    end
    return ans, chkd, othans
  end
  
  def build_answer(answer,ques_attr)
    ans, chkd, othans = getAnswerData(answer,ques_attr)
    if ques_attr[:required]
      isRequired = "required"
      if ques_attr[:this_ans_count] == ques_attr[:ans_count]
        oneRequired = "required-one"
      else
        oneRequired = nil
      end
    else
      isRequired = nil
    end
    otherQuestion = ""
    onclick = "toggleOther"    
    if answer.requires_other
      dsp = chkd ? ' style="display:block"' : ' style="display:none"'
      disabled = chkd ? false : true
      otherQuestion = "\n\t\t\t\t"+'<div class="assmnt-other-ques"  id="'+"qa_#{ques_attr[:quesID]}_#{answer.id.to_s}_other\""+ dsp +'>'
      otherQuestion += text_field_tag("post.answer_other[#{answer.id.to_s}]",othans, :id => "qa_#{ques_attr[:quesID]}_#{answer.id.to_s}_other_text", :disabled => disabled)
      otherQuestion += answer.other_question+'</div>'
    end
    if answer.answer.nil?
      answer.answer = ""
    end
    
    if ques_attr[:ansType] == "textarea"
      hidden_elem = hidden_field_tag("post.answer[#{ques_attr[:quesID]}][]",answer.id.to_s,:id => nil)
      input_elem = text_area_tag("post.answer[#{ques_attr[:quesID]}][]",ans, :class => isRequired, :id => "qat_#{ques_attr[:quesID]}_#{answer.id.to_s}",:rows => 3, :cols => 50)
      input = hidden_elem + input_elem
      answer = answer.answer
      
    elsif ques_attr[:isText]
      hidden_elem = hidden_field_tag("post.answer[#{ques_attr[:quesID]}][]",answer.id.to_s,:id => nil ) #"qa_#{ques_attr[:quesID]}_#{answer.id.to_s}"
      input_elem = text_field_tag("post.answer[#{ques_attr[:quesID]}][]",ans, :class => isRequired, :id => "qat_#{ques_attr[:quesID]}_#{answer.id.to_s}") 
      input = hidden_elem + input_elem
      answer = answer.answer
      
    elsif ques_attr[:ansType] == "checkbox"
      input = check_box_tag("post.answer[#{ques_attr[:quesID]}][]",answer.id.to_s,chkd, :class => oneRequired, :"data-behaviors" => onclick, :id => "qa_#{ques_attr[:quesID]}_#{answer.id.to_s}")
      answer = answer.answer
      
    elsif !(ques_attr[:ansType] =~ /radio/i).nil?
      input = radio_button_tag("post.answer[#{ques_attr[:quesID]}][]",answer.id.to_s,chkd, :class => oneRequired, :"data-behaviors" => onclick, :id => "qa_#{ques_attr[:quesID]}_#{answer.id.to_s}")
      answer = answer.answer
    else
      span = '<span class="assmnt-answer-input">Unknown Answer Type</span><span class="assmnt-answer-text">'+ques_attr[:ansType]+'</span>'
    end
    html = make_heredoc(:answer_input_first,input,answer)
    #html += make_heredoc(:other_questions,otherQuestion) if !otherQuestion.blank?
    
    result = make_heredoc(:answers,html,otherQuestion)
    return result
  end
  
  def build_textform_answers(question,ques_attr)
    html = make_heredoc(:answer_header,question.question)
    for answer in question.answers
      ans, chkd, othans = getAnswerData(answer,ques_attr)
      if question.score_method.downcase != "none"
        isRequired = "required"
      else
        isRequired = nil
      end
      if answer.answer.nil?
        answer.answer = ""
      end
      hidden_elem = hidden_field_tag("post.answer[#{question.id}][]",answer.id.to_s,:id => nil ) 
      input_elem = text_field_tag("post.answer[#{question.id}][]",ans, :class => isRequired, :id => "qat_#{question.id}_#{answer.id.to_s}") 
      input = hidden_elem + input_elem
      html += make_heredoc(:answer_input_last,input,answer.answer)
    end
    
    result = make_heredoc(:answers,html)
    return result
  end
  
  def build_select_answers(question,ques_attr)
    if ques_attr[:required]
      isRequired = "required"
    else
      isRequired = nil
    end
    multiple = ques_attr[:ansType] == "select-multiple"
    opt = %Q(  <option value="">--Select--</option>)
    for answer in question.answers
      ans, chkd, othans = getAnswerData(answer,ques_attr)
      selected = chkd ? 'selected="selected"' : ""
      opt += %Q(<option value="#{answer.id.to_s}" #{selected}>#{answer.answer}</option>)
    end
    
    input =  select_tag("post.answer[#{question.id}][]",opt.html_safe,:class => isRequired,:multiple => multiple)
    
    if multiple
      inst = 'Use Cmd or Ctrl click to select multiple responses'
    else 
      inst = 'Select response from pulldown options'
    end
    html = make_heredoc(:answer_header,format_question(question))
    html += make_heredoc(:answer_input_first,input,inst)
    result = make_heredoc(:answers,html)
    return result
  end
  
  def build_inline_answers(question,ques_attr)
    ques_attr[:ans_count] = question.answers.count
    ques_attr[:this_ans_count] = 0
    
    span = ""
    otherQuestion = ""
    for answer in question.answers
      ans, chkd, othans = getAnswerData(answer,ques_attr)
      ques_attr[:this_ans_count] += 1
      if ques_attr[:this_ans_count] == ques_attr[:ans_count]
        oneRequired = "required-one"
      else
        oneRequired = nil
      end
      onclick = "toggleOther"    
      
      if answer.requires_other
        dsp = chkd ? ' style="display:block"' : ' style="display:none"'
        disabled = chkd ? false : true
        otherQuestion += '<div class="assmnt-other-ques" id="'+"qa_#{ques_attr[:quesID]}_#{answer.id.to_s}_other\""+ dsp +'>'
        otherQuestion += text_field_tag("post.answer_other[#{answer.id.to_s}]",othans, :id => "qa_#{ques_attr[:quesID]}_#{answer.id.to_s}_other_text", :disabled => disabled)
        otherQuestion += "[#{answer.answer}] "+answer.other_question+'</div>'  
      end
      if ques_attr[:ansType] == "checkbox"
        input_elem = check_box_tag("post.answer[#{ques_attr[:quesID]}][]",answer.id.to_s,chkd, :class => oneRequired, :"data-behaviors" => onclick,  :id => "qa_#{ques_attr[:quesID]}_#{answer.id.to_s}")
        span += '<span class="assmnt-answer-input">'+input_elem+' '+answer.answer+'</span>'
      elsif !(ques_attr[:ansType] =~ /radio/i).nil?
        input_elem = radio_button_tag("post.answer[#{ques_attr[:quesID]}][]",answer.id.to_s,chkd, :class => oneRequired, :"data-behaviors" => onclick,  :id => "qa_#{ques_attr[:quesID]}_#{answer.id.to_s}")
        span += '<span class="assmnt-answer-input">'+input_elem+' '+answer.answer+'</span>'
      else
        span += '<span class="assmnt-answer-input">Unknown Answer Type</span>'
      end
    end
    
    html = make_heredoc(:answer_input_first_bold,span,format_question(question))
    #html += make_heredoc(:other_questions,otherQuestion) if !otherQuestion.blank?
    result = make_heredoc(:answers,html,otherQuestion)
    return result
  end
  
  def build_question(question)
    html = ""
    if !(question.display_type =~ /none/i).nil?
      return(html)
    end
    selectDisplay = !(question.answer_type =~   /select/i).nil?
    isTextform = !(question.answer_type =~  /textform/i).nil?
    isInline = !(question.display_type =~ /inline/i).nil?
    ques_attr = {:required => question.score_method != "none",
      :quesID => question.id.to_s,
      :ansType => question.answer_type.downcase,
      :isText => !(question.answer_type =~  /text/i).nil? }
    
    if (selectDisplay )
      answers =  build_select_answers(question,ques_attr)
    elsif (isInline)
      answers =  build_inline_answers(question,ques_attr)
    elsif (isTextform)
      answers =  build_textform_answers(question,ques_attr)
    else
      ques_attr[:ans_count] = question.answers.count
      ques_attr[:this_ans_count] = 0
      html <<  make_heredoc(:question_header,format_question(question) )
      for answer in question.answers
        ques_attr[:this_ans_count] += 1
        html <<  build_answer(answer,ques_attr)
      end
      answers = html #make_heredoc(:answers,html)
    end
    if !question.group_header.blank?
      queshead = question.group_header
    else
      queshead = ""
    end
    ques = <<QUES
    <div class="assmnt-question " id="q_#{question.id.to_s}">
      <div class="assmnt-question-header">#{queshead}</div>
      #{answers}
    </div>  
QUES
    return ques
  end

  def display_assessment(assessment)
    html = ""
    for question in assessment.questions
      html << build_question(question)
      
    end
    assmnt = %Q(
    <div id="assmnt">
        #{html}
    </div>
)
    return assmnt.html_safe
  end

  def make_heredoc(label,data,data2="")

    if data.nil?
      return ""
    end
    if data == ""
      return ""
    end

    case label
    when :question_header
      result = %Q(        <div class="assmnt-question-header">#{data}</div>)
    when :answer_header
      result = %Q(          <tr><td class="assmnt-answer-header" colspan="2">#{data}</td></tr>\n)
    when :other_questions
      result = %Q(          <tr><td class="assmnt-other-questions" colspan="2">#{data}</td></tr>\n)
    when :answer_input_first
      result = %Q(
            <tr>
              <th class="assmnt-answer">#{data}</th>
              <td class="assmnt-answer-text">#{data2}</td>
            </tr>
)
    when :answer_input_first_bold
      result = %Q(
            <tr>
              <th class="assmnt-answer">#{data}</th>
              <td class="assmnt-answer-text-bold">#{data2}</td>
            </tr>
)
    when :answer_input_last
      result = %Q(
            <tr>
              <th class="assmnt-answer-text-bold">#{data2}</th>
              <td class="assmnt-answer">#{data}</td>
            </tr>
)
    when :answers
      result = %Q(
        <table class="assmnt-answers">
          #{data}
        </table>
        #{data2}
)
      
    else
      result = ""
    end
    return result
  end
    
end

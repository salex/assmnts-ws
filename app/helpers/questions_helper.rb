module QuestionsHelper
  
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
  
end

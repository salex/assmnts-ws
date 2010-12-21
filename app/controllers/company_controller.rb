class CompanyController < ApplicationController
  def index
    if (current_user.user_type == "project") || current_user.admin?
      @stages  = Stage.all
    else
      projects = current_user.roles.gsub(/[^0-9\|]/,"").split("|")
      projects.delete("")
      projects =  projects.map{|s| s.to_i} 
      @stages = Stage.where(:project_id => projects)
    end
  end
  
  def search
    @stage = Stage.find(params[:id])
    @applicants = @stage.stage_applicants(params).paginate(:per_page => 20, :page => params[:page])
  end
  
  def select
    stage = Stage.find(params[:id])
    request = params[:applicant][:fullpath]
    params[:current_user_id] = current_user.id
    result = stage.process_selection(params)
    redirect_to request, :notice => result
  end
  
  def qa_summary
    assessment_summary
  end
  
  def assessment_summary
    stage = Stage.find(params[:id])
    assessors = stage.assessors
    html = "<h4>Assessment QA Summary</h4>"
    html << "<div class=\"actions\"><div class=\"annotate\" style=\"width:650px\">"
    stuff = "<p>Okay, this is not that hard! Assessments have many questions that have many answers.
    Each answer (and question) has a key that is basically the first character of the category
    (w = work experience, g = general, s= skills, e = education, c = custom) and then
    the sequence number of the question followed by the sequence number of the answer.</p>
    <p>e0107 is the 7th answer for the 1st question in the education area<p>
    <p>To find who had that answer, simply put in e0107 into the aKey search box</p>
    <p>You can AND or OR answers e0107|e0108 looks for answers e0107 OR e0108.
    e0107&e0108 looks for answers e0107 AND e0108.</p>
    <p>You can nest queries by using parentheses <br />
    (e0107|e0108)&(c0404|c0405|c0406) = anyone who answered military training or some associate work and 4 or more years in telephone support!
    etc., etc.</p>
    "
    
    
    
    html << "#{stuff}</div></div>"
    assessors.each do |ass|
      html << answer_keys(ass.assessment_id)
    end
    render :text => html, :layout => true
    
  end
  
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
    html
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
    html = "<div class=\"f-left little-box\">#{answer.xml_key.gsub("_","").delete(answer.xml_key.slice(1..1))} - #{answer.shortname.blank? ? truncateText(answer.answer,30,"middle") : truncateText(answer.shortname,30,"middle") }</div>"
  end
  
end

class ApplyController < ApplicationController
  def first
    @citizen = Citizen.find(current_user.id)
    @sidebar = ""
    cbc = '<input type="checkbox" checked="checked" disabled="disabled" />'
    cb = '<input type="checkbox" disabled="disabled" />'
    @sidebar << "<p>#{cb} Profile</p>"
    
    session[:steps].each do |key,value|
      section = session[:steps][key][:section]
      if session[:steps][key][:complete]
        @sidebar << "<p><a href=\"/apply/area?aid=#{session[:steps][key][:id]}\" >#{cbc} #{section}</a></p>"
      else
        @sidebar << "<p>#{cb} #{section}</p>"
      end
    end
    
  end
  
  def profile
    render :text => "hi profile" #post on profile
  end
  
  
  
  def area
    if session[:take].nil?
      redirect_to root_url, :alert => "Your have been logged out or something else screwed up"
    else
      aid = params[:aid] ? params[:aid] : nil
      area = "unknown"
      finished = true
      @sidebar = ""
      cbc = '<input type="checkbox" checked="checked" disabled="disabled" />'
      cb = '<input type="checkbox" disabled="disabled" />'
      @sidebar << "<p><a href=\"/apply/first\">#{cbc} Profile</a></p>"
    
      session[:steps].each do |key,value|
        section = session[:steps][key][:section]
        if session[:steps][key][:complete]
          @sidebar << "<p><a href=\"/apply/area?aid=#{session[:steps][key][:id]}\" >#{cbc} #{section}</a></p>"
          if !aid.nil?
            area = session[:steps][key][:section] if session[:steps][key][:id] == aid.to_i
          end
        else
          area = section  if aid.nil?
          aid = session[:steps][key][:id] if aid.nil?
          @sidebar << "<p>#{cb} #{section}</p>"
          finished = false
        end
        
      end
      session[:take][:current_area] = area
      session[:take][:aid] = aid
      if finished && aid.nil?
        make_summary
        render :template => "apply/confirm"      
      else
        @assessor = Assessor.find(aid)
        @assessment = @assessor.assessment
        params[:model_id] = session[:take][:assessed_id]
        @score = Score.get_or_create_score(@assessor,params)
        session[:take][:score_ids] << @score.id
        if !@score.score_object.blank?
          params[:post] = json_parse(@score.score_object)
        end
        render :template => "apply/display"      
      end
    end
  end
  
  def next
    if  session[:take]
      @assessor = Assessor.find(params[:id])
      @assessment = Assessment.find(@assessor.assessment_id)
      category = @assessment.category
      @score = Score.find(params[:score_id])
      result = @assessment.scoreAssessment(params)
      @score.answers = "|" + result["all_answers"].join("|") + "|"
      # for summary
      session[:take][:total_raw] += result["total_raw"]
      session[:take][:total_weighted] += result["total_weighted"]
      session[:take][:max_raw] += result["max_raw"]
      session[:take][:max_weighted] += result["max_weighted"]
      session[:take][:answers] +=  @score.answers
      
      @score.score_object = result.to_json
      @score.status = "Completed"
      @score.score =  result["score_raw"]
      @score.score_weighted =  result["score_weighted"]
      @score.save
      session[:steps][category][:complete] = true
      area # see if any more assessments
    else
      #TODO need error and redirect
      render :text => params.inspect
    end
  end
  
  def confirm
    applicant = Applicant.find(session[:take][:assessed_id])
    @profile = applicant.display_profile
    render :template => "apply/display_profile"
  end
  
  def make_summary
      summary_score = 0
      summary_score_weighted = 0
      if session[:take][:max_raw] > 0
        summary_score = (session[:take][:total_raw] / session[:take][:max_raw]) * 100 
      end
      if session[:take][:max_weighted] > 0
        summary_score_weighted = (session[:take][:total_weighted] / session[:take][:max_weighted]) * 100 
      end
      applicant = Applicant.find(session[:take][:assessed_id])
      if !applicant.nil?
        applicant.score = summary_score
        applicant.weighted = summary_score_weighted
        applicant.answers =  session[:take][:answers].gsub("||","|")
        applicant.status = "Completed"
        applicant.status_date = Date.today
        applicant.save
      end
  end
  
  def json_parse(json)
    return ActiveSupport::JSON.decode(json)
  end

end
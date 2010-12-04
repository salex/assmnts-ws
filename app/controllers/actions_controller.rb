class ActionsController < ApplicationController

  def take
    #reset_session
    if !session[:steps]
      session[:steps] = {}
      session[:take] ={}
      session[:take][:assessed_id] = params[:assessed_id]
      session[:take][:assessing_id] =  params[:id]
      session[:take][:assessed] =  params[:assessed]
      session[:take][:total_raw] = 0
      session[:take][:total_weighted] = 0
      session[:take][:max_raw] = 0
      session[:take][:max_weighted] = 0
      session[:take][:answers] = ""
      session[:take][:score_ids] = []
      if params[:assessed].downcase == "default"
        assessors = Assessor.order(:sequence).where(:id => params[:id])
      else
        assessors = Assessor.order(:sequence).where(:assessing_id => params[:id])
      end
      for assessor in assessors do
        category = assessor.assessment.category
        session[:steps][category] = {}
        session[:steps][category][:id] = assessor.id
        session[:steps][category][:complete] = false
      end
    end
    finished = true
    @sidebar = ""
    aid = params[:aid] ? params[:aid] : nil
    cbc = '<input type="checkbox" checked="checked" disabled="disabled" />'
    cb = '<input type="checkbox" disabled="disabled" />'
    
    session[:steps].each do |key,value|
      chunks = key.split(".")
      section = chunks[1].capitalize
      if session[:steps][key][:complete]
        @sidebar << "<p><a href=\"/actions/take/0/model/0?aid=#{session[:steps][key][:id]}\" >#{cbc} #{key}</a></p>"
        
      else
        aid = session[:steps][key][:id] if aid.nil?
        @sidebar << "<p>#{cb} #{section}</p>"
        finished = false
      end
    end
    session[:take][:aid] = aid
    if finished
      if session[:steps].length > 1
        make_summary
      end
      render :text => "I be finished! #{session.inspect}"
      
      session[:steps] = nil
      session[:take] = nil
    else
      @assessor = Assessor.find(aid)
      @assessment = @assessor.assessment
      params[:model_id] = session[:take][:assessed_id]
      @score = Score.get_or_create_score(@assessor,params)
      session[:take][:score_ids] << @score.id
      if !@score.score_object.blank?
        params[:post] = json_parse(@score.score_object)
      end
      render :template => "actions/display"      
    end
    
    #render :text => params.inspect+" \n" + session.inspect + step.inspect
  end
  
  def post
    if  session[:take]
      @assessor = Assessor.find(params[:id])
      @assessment = Assessment.find(@assessor.assessment_id)
      category = @assessment.category
      @score = Score.find(params[:assessed_id])
      result = @assessment.scoreAssessment(params)
      @score.answers = "|" + result["all_answers"].join("|") + "|"
      # for summary
      session[:take][:total_raw] += result["total_raw"]
      session[:take][:total_weighted] += result["total_weighted"]
      session[:take][:max_raw] += result["max_raw"]
      session[:take][:max_weighted] += result["max_weighted"]
      session[:take][:answers] +=  @score.answers
      
      @score.score_object = result.to_json
      @score.status = "complete"
      @score.score =  result["score_raw"]
      @score.score_weighted =  result["score_weighted"]
      @score.save
      session[:steps][category][:complete] = true
      take # see if any more assessments
      #render :text => params.inspect + session.inspect
      
    else
      render :text => params.inspect
    end
  end
  
  def make_summary
    # this is an example of how to summarize a muliti-assessement and post an overall score
    # for demo purposes, the scored is stored in both the generic score stub and candidate stub.
      clone = Score.where(:parent_id => session[:take][:assessing_id], :assessed_id => session[:take][:assessed_id] ).last
      if clone.nil?
        clone = Score.find(session[:take][:score_ids][0]).clone
        clone.parent_id = clone.assessing_id
      end
      clone.answers = session[:take][:answers].gsub("||","|")
      clone.assessor_id = nil
      clone.score_object = nil
      clone.status = "summary"
      clone.score = 0
      clone.score = 0
      clone.score_weighted = 0
      if session[:take][:max_raw] > 0
        clone.score = (session[:take][:total_raw] / session[:take][:max_raw]) * 100 
      end
      if session[:take][:max_weighted] > 0
        clone.score_weighted = (session[:take][:total_weighted] / session[:take][:max_weighted]) * 100 
      end
      clone.save
      candidate = Candidate.find(session[:take][:assessed_id])
      if !candidate.nil?
        candidate.score = clone.score
        candidate.save
      end
  end
  
  def json_parse(json)
    return ActiveSupport::JSON.decode(json)
  end

end
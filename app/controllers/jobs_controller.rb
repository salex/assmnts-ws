class JobsController < ApplicationController
  
  def index
    @stages = Stage.all
  end
  
  def view
    @stage = Stage.find(params[:id])
  end
  
  def apply
    stage = Stage.find(params[:id])
    last_apply = Applicant.where(:user_id => current_user.id).where("stage_id != #{stage.id}").last
    
    applicant = stage.get_or_create_applicant(current_user.id)
    #TODO Need to check status != new or completed or !accepted or whatever that statuses are
    if applicant.application_reviewed?
      redirect_to opps_welcome_index_path, :notice => "Were sorry, but you have already applied for this training and your application is under review"
    else
      
      session[:steps] = {}
      session[:take] ={}
      session[:take][:assessed_id] = applicant.id #params[:assessed_id]
      session[:take][:assessing_id] =  params[:id]
      session[:take][:assessing_type] =  "Stage" #params[:assessed]
      session[:take][:current_area] = "Profile"
      session[:take][:last_apply_id] = last_apply.nil? ? nil : last_apply.id
      assessors = Assessor.order(:sequence).where(:assessing_id => params[:id])
      for assessor in assessors do
        category = assessor.assessment.category
        chunks = category.split(".")
        section = chunks[1].capitalize
        session[:steps][assessor.sequence] = {}
        session[:steps][assessor.sequence][:id] = assessor.id
        session[:steps][assessor.sequence][:complete] = false
        session[:steps][assessor.sequence][:section] = section
        session[:steps][assessor.sequence][:score_id] = nil
        session[:steps][assessor.sequence][:total_raw] = 0
        session[:steps][assessor.sequence][:total_weighted] = 0
        session[:steps][assessor.sequence][:max_raw] = 0
        session[:steps][assessor.sequence][:max_weighted] = 0
        session[:steps][assessor.sequence][:failed] = false
        session[:steps][assessor.sequence][:answers] =  ""
        
      end
      redirect_to "/apply/first"
      #render :text => session.inspect, :layout => true
    end
  end
  
end

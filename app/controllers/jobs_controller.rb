class JobsController < ApplicationController
  def index
    @stages = Stage.all
  end
  
  def view
    @stage = Stage.find(params[:id])
  end
  
  def apply
    stage = Stage.find(params[:id])
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
      #ession[:take][:total_raw] = 0 #remove
      #sesssion[:take][:total_weighted] = 0 #remove
      #session[:take][:max_raw] = 0 #remove
      #session[:take][:max_weighted] = 0 #remove
      #session[:take][:answers] = "" #remove
      #session[:take][:score_ids] = [] #remove
      session[:take][:current_area] = "Profile"
      assessors = Assessor.order(:sequence).where(:assessing_id => params[:id])
      for assessor in assessors do
        category = assessor.assessment.category
        chunks = category.split(".")
        section = chunks[1].capitalize
        #session[:steps][category] = {} #remove
        #session[:steps][category][:id] = assessor.id #remove
        #session[:steps][category][:complete] = false #remove
        #session[:steps][category][:section] = section #remove
        #session[:steps][category][:score_id] = nil #remove
        #session[:steps][category][:total_raw] = 0 #remove
        #session[:steps][category][:total_weighted] = 0 #remove
        #session[:steps][category][:max_raw] = 0 #remove
        #session[:steps][category][:max_weighted] = 0 #remove
        #session[:steps][category][:answers] =  "" #remove
        session[:steps][assessor.sequence] = {}
        session[:steps][assessor.sequence][:id] = assessor.id
        session[:steps][assessor.sequence][:complete] = false
        session[:steps][assessor.sequence][:section] = section
        session[:steps][assessor.sequence][:score_id] = nil
        session[:steps][assessor.sequence][:total_raw] = 0
        session[:steps][assessor.sequence][:total_weighted] = 0
        session[:steps][assessor.sequence][:max_raw] = 0
        session[:steps][assessor.sequence][:max_weighted] = 0
        session[:steps][assessor.sequence][:answers] =  ""
        
      end
      redirect_to "/apply/first"
      #render :text => session.inspect, :layout => true
    end
  end
  
end

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
    if !applicant.status.in?(Applicant::CAN_APPLY)
      redirect_to opps_welcome_index_path, :notice => "Were sorry, but you have already applied for this training and your application is under review"
    else
      session[:steps] = {}
      session[:take] ={}
      session[:take][:assessed_id] = applicant.id #params[:assessed_id]
      session[:take][:assessing_id] =  params[:id]
      session[:take][:assessing_type] =  "Stage" #params[:assessed]
      session[:take][:total_raw] = 0
      session[:take][:total_weighted] = 0
      session[:take][:max_raw] = 0
      session[:take][:max_weighted] = 0
      session[:take][:answers] = ""
      session[:take][:score_ids] = []
      session[:take][:current_area] = "Profile"
      assessors = Assessor.order(:sequence).where(:assessing_id => params[:id])
      for assessor in assessors do
        category = assessor.assessment.category
        chunks = category.split(".")
        section = chunks[1].capitalize
        session[:steps][category] = {}
        session[:steps][category][:id] = assessor.id
        session[:steps][category][:complete] = false
        session[:steps][category][:section] = section
      end
      redirect_to "/apply/first"
      #render :text => session.inspect, :layout => true
    end
  end
  
end

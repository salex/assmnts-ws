class PdfController < ApplicationController

def show
  export = Export.where(:token => params[:id]).last
  if export
    @applicant = Applicant.find(export.user_id)
    @applicants = [@applicant]
    export.delete
    render :template => "/applicants/profiles", :layout => "print"
  else
    render :text => "Sorry, I could not find what your were looking for"
  end
  
  
  #render :text => session.inspect
end

def create
  applicant = Applicant.joins(:user).where("users.citizen_id" => params["citizen_id"]).joins(:stage).where("stages.jobstage_id" => params["jobstage_id"]).first
  #@applicants = [@applicant]
  if applicant
    token = Devise.friendly_token
    export = Export.new
    export.token =  token
    export.user_id = applicant.id
    export.status = "PDF"
    export.sent = Time.now
    export.request = params.to_json
    export.save
    #@scores = @applicant.stage.get_applicant_scores(@applicant)
    #@citizen = @applicant.user
    #render :template => "/applicants/profiles", :layout => "print"
    render :text => token
  else
    render :text => "Error - could not find what you were looking for"
  end
end
  
  
end
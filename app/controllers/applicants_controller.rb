class ApplicantsController < ApplicationController

  # GET /applicants/1
  # GET /applicants/1.xml
  load_and_authorize_resource
  def index
    #@applicant = Applicant.find(params[:id])
    @applicants = Applicant.all.paginate(:per_page => 20, :page => params[:page])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @applicant }
    end
  end
  
  def show
    #@applicant = Applicant.find(params[:id])
    @profile = @applicant.display_profile
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @applicant }
    end
  end
  
  def profile
    #@applicant = Applicant.find(params[:id])
    result = @applicant.status.include?("conv.") ? @applicant.conv_4d_scores : true
    if result
      #@scores = @applicant.stage.get_applicant_scores(@applicant)
      #@citizen = @applicant.user
      @applicants = [@applicant]
      respond_to do |format|
        format.html {render :template => "applicants/profiles", :layout => "print"}
        format.xml  { render :xml => @applicant }
      end
    else
      render :text => "Applicant does not have scores and was unable to convert scores from 4D", :layout => true
    end
  end

  
  def rescore
    #@applicant = Applicant.find(params[:id])
    @applicant.rescore
    redirect_to @applicant
  end
  
  def profiles
    ids = session[:ids].collect {|i| i.to_i}
    @applicants = Applicant.where(:id => ids)
    render :template => "applicants/profiles", :layout => "print"
  end
  
end

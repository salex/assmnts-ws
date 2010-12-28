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
    stage = Stage.find(params[:id])
    @assessors = stage.assessors
    render :template => "company/qa_summary", :layout => "print"
    
  end
  
  
end

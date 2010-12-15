class CompanyController < ApplicationController
  def index
    if current_user.user_type == "project"
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
    render :text => params.inspect
  end
end

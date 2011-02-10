module Admin
  class DbaController < BaseController
    def index
      render :text => "hi dba"
    end
  
    def assessors
      @assessors = Assessor.paginate(:per_page => 20, :page => params[:page])
    end
    
    def users
      @users = Dba.search(params).paginate(:per_page => 20, :page => params[:page])
    end
  end
end

class WelcomeController < ApplicationController
  def index
    if !user_signed_in? 
      @user = User.new
    end
  end
  
  def citizen
    check_type("citizen")
    @applications = Applicant.where(:user_id => current_user.id)
  end
  
  def admin
    check_type("admin")
  end
  
  def project
    check_type("project")
  end
  
  def company
    check_type("company")
  end
  
  def opps
  end
  private
  def check_type(utype)
    if !user_signed_in? || current_user.user_type != utype
      render_404
      return false
    end 
    
  end
end

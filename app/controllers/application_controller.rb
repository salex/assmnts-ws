include Assmnt

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    logger.info exception.message
    redirect_to "/opps" 
  end


  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "Sorry, I could not find the page you requested."
    redirect_to "/welcome/opps" 
  end
  
  private

  def after_sign_in_path_for(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    case current_user.user_type
    when "admin"
      user_session[:namespace] = current_user.user_type
      return admin_welcome_index_path
    when "company"
      user_session[:namespace] = current_user.user_type
      return company_welcome_index_path
    when "project"
      user_session[:namespace] = current_user.user_type
      return project_welcome_index_path
    when "citizen"
      user_session[:namespace] = current_user.user_type
      return citizen_welcome_index_path
      
    else
      user_session[:namespace] = 'citizen'
      super
    end
  end
  
  def after_sign_out_path_for(resource_or_scope)
    reset_session
    root_path
  end
  
  def render_404(exception = nil)
    if exception
        logger.info "Rendering 404: #{exception.message}"
    end

    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
  
  
end

  

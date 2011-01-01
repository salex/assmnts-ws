module ApplicationHelper
  def build_navbar
    navbar =  (link_to 'jobs.aidt.edu', root_path)
    if user_signed_in?
      case current_user.user_type
      when "admin"
        navbar << (link_to "My Dashboard", admin_welcome_index_path, :class => "#{params["action"] == "admin" ? "set" : ""}")
        navbar << (link_to "Assessments", group_admin_assessments_path, :class => "#{params["action"] == "assessments" ? "set" : ""}")
        navbar << (link_to "Assessors", assessors_admin_dba_index_path, :class => "#{params["assessors"] == "admin" ? "set" : ""}")
        navbar << (link_to "Stages(jobs)", stages_path, :class => "#{params["assessors"] == "admin" ? "set" : ""}")
        navbar << (link_to "Users", users_admin_dba_index_path)
        
      when "company"
        navbar << (link_to "My Dashboard", company_welcome_index_path, :class => "set")
        navbar << (link_to "Jobs",company_index_path)
      when "project"
        navbar << (link_to "My Dashboard", project_welcome_index_path, :class => "set")
        navbar << (link_to "Jobs",company_index_path)
        
      when "citizen"
        navbar << (link_to "Dashboard", citizen_welcome_index_path)
        navbar << (link_to "Jobs",jobs_path)
      else
      end
    else
      navbar << (link_to "Jobs",jobs_path)
    end
    return  navbar.html_safe
  end
  def format_money(value,dollar=false)
    if value.nil?
      return 
    end
    if dollar
      result = number_to_currency(value)
    else
      result = ("%0.2f" % value)
    end
  end
  
end

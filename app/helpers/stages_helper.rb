module StagesHelper
  
  def stage_status_options(status)
    if status.nil?
      status = ""
    end
    types = {"Unknown" => "", "Active" => "Active", "Inactive" => "Inactive", "Dirty" => "Dirty"}
    result = options_for_select(types,status.capitalize)
    return result.html_safe
  end
  
end

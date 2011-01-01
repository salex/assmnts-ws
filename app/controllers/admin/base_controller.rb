# in controllers/admin/base_controller.rb
module Admin
  class BaseController < ApplicationController
    # common behavior goes here ...
    before_filter :verify_admin
    
    private
    def verify_admin
      if !user_signed_in? || !current_user.admin?
        render_404
        #render '/404', :status => 404, :layout => false
        return false
      end 
    end
    
  end
end

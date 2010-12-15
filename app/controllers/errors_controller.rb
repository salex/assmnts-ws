class ErrorsController < ApplicationController
  def routing
    render_404
   #render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end

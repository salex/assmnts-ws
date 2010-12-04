class WsController < ApplicationController
  
  def get_xml_assmnt
    assmnt =  %x[curl --form-string  'fdata=#{params[:id]}' 'http://localhost:8080/ws.jobstage.get_xml_assmnt']
    hash = ActiveSupport::JSON.decode(assmnt)
    
    render :text => "<textarea>#{assmnt}</textarea>", :layout => true
  end

end
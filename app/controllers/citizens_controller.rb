class CitizensController < ApplicationController

  load_and_authorize_resource :only => [:show, :edit, :update]
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end

  def new
    resource = User.new
    
  end
  
  def get
    citizen =  %x[curl --form-string  'fdata=#{params[:id]}' 'http://localhost:8080/ws.citizen.get']
    
    render :text => citizen, :layout => true
    
  end
  
  def find
    @citizen = Citizen.new
  end

  def lookup
    attributes = params[:citizen]
    #attributes["name_full"] = attributes["name_last"]+", "+ attributes["name_first"]
    citizen = Citizen.lookup_citizen(attributes)
    logger.info "AAAAAAAAAAAAAAAAAAAAAAAAAA #{citizen.inspect}"
    if citizen.has_key?("citizen")
      session["citizen"] = citizen
      redirect_to new_user_registration_path, :notice => "Information has been found matching your input. 
      <br />If this is not you, click the sign-in link on the bottom of the page.".html_safe
    else
      session["citizen"] ={} 
      session["citizen"]["citizen"] = attributes
      redirect_to new_user_registration_path, :notice => "No previous information found. "
            
    end
  end

  def update

    respond_to do |format|
      if @citizen.update_attributes(params[:citizen])
        format.html { redirect_to(@citizen, :notice => 'Member was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @citizen.errors, :status => :unprocessable_entity }
      end
    end
  end

end

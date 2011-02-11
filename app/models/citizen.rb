class Citizen < User
  validates_presence_of  :address, :city, :state, :zip, :phone_primary,:birth_mm, :birth_dd,:name_first, :name_last
  def self.lookup_citizen(params)
    #first check the users table
    result, citizen = self.find_citizen(params)        
    if !result 
      fdata = params.to_json
      citizen =  a4d_fcurl(fdata,"ws.citizen.lookup")
      if citizen[0..0] == "{"
        citizen = ActiveSupport::JSON.decode(citizen)
      else
        citizen = {"error" => citizen, "fdata" => fdata}
      end
    else
      citizen = {"error" => "Already registered", "user_id" => citizen.id}
    end
    return citizen
  end
  
  private 
  
  
  def self.find_citizen(params)
    citizens = scoped
    #citizens = citizens.where(:birth_mm => params[:birth_mm], :birth_dd => params[:birth_dd])
    citizens_email = citizens.where(:email => params[:email])
    if citizens_email.length == 1
      return true, citizens_email.first
    end
    citizens_phone =  citizens.where(:phone_primary => params[:phone_primary])
    if citizens_phone.length == 1
      return true, citizens_phone.first
    end
    if citizens_phone.length > 1
      citizens_phone = citizens_phone.where(:name_first => params[:name_first]) 
    end
    #can add more
    if citizens_phone.length == 1
      return true, citizens_phone.first
    else
      return false, {}
    end
  end
  
  
end

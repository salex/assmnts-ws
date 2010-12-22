class Dba < User
  
  def self.search(params)
    users = scoped
    if params[:filter]
      users = users.order(:name_full)
    else
      users = users.order(:name_full)
    end
    if params[:type] && (params[:type] != "" && params[:type] != "All")
      users = users.where('user_type LIKE ?', "%#{params[:type]}%")
    end 
    if params[:name] && params[:name] != ""
      users = users.where('users.name_full LIKE ?', "%#{params[:name]}%")
    end
    if params[:phone] && params[:phone] != ""
      users = users.where('users.phone_primary LIKE ?', "#{params[:phone]}%")
    end
    if params[:email] && params[:email] != ""
      users = users.where('users.email LIKE ?', "#{params[:email]}%")
    end
    users
  end
  
end

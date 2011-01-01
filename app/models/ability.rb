#ability.rb
class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new  
    can [:update,:read], Citizen do |citizen|  
      citizen.try(:id) == user.id  
    end
    can [:find,:lookup], Citizen
    if user.user_type == "admin"
      can :manage, :all
    elsif user.user_type  == "company"
      can [:read,:profile], Applicant
    elsif user.role? :site_admin
    elsif user.role? :admin
    elsif user.role? :designer
      
    else
    end
    #can :manage, :all if user.roles.nil? ? false : user.role?("super_admin")
    
  end
end

#ability.rb
class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new  
    can [:update,:read], Citizen do |citizen|  
      citizen.try(:id) == user.id  
    end
    can [:find,:lookup], Citizen
    if user.role? :super_admin
      can :manage, :all
    elsif user.role? :site_admin
      can :manage, [Estimate,Task,Task_item,Sales_order,Coa,Customer, Vendor, Sales_order,Purchase_order,Memo]
    elsif user.role? :admin
    elsif user.role? :designer
      
    else
    end
    #can :manage, :all if user.roles.nil? ? false : user.role?("super_admin")
    
  end
end

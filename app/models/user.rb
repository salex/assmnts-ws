class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable, :confirmable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

         before_validation :set_name_full
         validates_uniqueness_of  :email, :case_sensitive => false
         validates_presence_of :name_first, :name_last, :address, :city, :state, :zip, :phone_primary,:birth_mm, :birth_dd
         before_create :create_login
         
         attr_accessor :no_email  # used to ???
         attr_accessible :email, :password, :password_confirmation, :remember_me, :login, :phone_primary, :phone_secondary, :user_type, :name_first,:name_last, :name_mi, :address, :city, :state, :zip, :challenge,:birth_mm, :birth_dd
         after_create :set_no_email_confirm
         after_update :set_no_email_confirm
         
  # Setup accessible (or protected) attributes for your model
  def set_name_full
    self.name_first = self.name_first.capitalize
    self.name_last = self.name_last.capitalize
    self.name_mi = self.name_mi.capitalize
    self.phone_primary = self.phone_primary.gsub(/[^0-9]/,"")
    self.phone_secondary = self.phone_secondary.gsub(/[^0-9]/,"")
    self.name_full = self.name_last+", "+self.name_first + " " + self.name_mi
    if self.email.blank?
      self.email = self.login+"@jobs.aidt.edu"
    end
    
  end
  
  def set_no_email_confirm
    if self.email.include?("jobs.aidt.edu") && !self.confirmed?
      self.confirm!
      self.save
    end
  end
  def self.valid?(params)
    token_user = self.where(:loginable_token => params[:id]).first
    if token_user
      token_user.loginable_token = nil
      token_user.save
    end
    return token_user
  end
  
  def self.find_for_database_authentication(conditions)
    self.where(:login => conditions[:email]).first || self.where(:email => conditions[:email]).first
  end
  
  def role?(role)
      return self.roles.nil? ? false : self.roles.include?(role.to_s)
  end
  
  def self.find_for_database_authentication(conditions)
    self.where(:login => conditions[:email]).first || self.where(:email => conditions[:email]).first
  end
  
  def create_login  
    self.email = ""
    return           
    email = self.email.split(/@/)
    login_taken = User.where( :login => email[0]).first
    unless login_taken
      self.login = email[0]
    else	
      self.login = self.email
    end	       
  end
  
  
end

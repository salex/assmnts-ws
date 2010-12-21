class User < ActiveRecord::Base
  
  has_many :applicants
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable, :confirmable
  devise :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

         before_validation :set_defaults
         validates_uniqueness_of  :email, :case_sensitive => false
         validates_presence_of :email
         before_create :create_login
         
         attr_accessor :no_email  # used to ???
         attr_accessible :email, :roles, :password, :password_confirmation, :remember_me, :login, :phone_primary, :phone_secondary, :user_type, :name_first,:name_last, :name_mi, :address, :city, :state, :zip, :challenge,:birth_mm, :birth_dd, :citizen_id
         after_create :set_no_email_confirm
         after_update :set_no_email_confirm
         
  # Setup accessible (or protected) attributes for your model
  def set_defaults
    self.name_first = self.name_first.capitalize
    self.name_last = self.name_last.capitalize
    self.name_mi = self.name_mi.nil? ? "" : self.name_mi.capitalize
    self.name_full = self.name_last+", "+self.name_first + " " + self.name_mi
    self.login = self.login.downcase if !self.login.nil?
    self.email = self.email.downcase if !self.email.nil?
    
    if self.user_type == "citizen"
      self.phone_primary = self.phone_primary.gsub(/[^0-9]/,"")
      self.phone_secondary = self.phone_secondary.gsub(/[^0-9]/,"")
      if self.email.blank?
        self.email = self.login+"@jobs.aidt.edu"
      end
    end
  end
  
  def set_no_email_confirm
    if self.email.include?("jobs.aidt.edu") && !self.confirmed?
      self.confirm!
      self.save
    end
  end
  
  def self.login_valid?(params)
    token_user = self.where(:loginable_token => params[:id]).first
    if token_user
      token_user.loginable_token = nil
      token_user.save
    end
    return token_user
  end
    
  def role?(role)
      return self.roles.nil? ? false : self.roles.include?(role.to_s)
  end
  
  def admin?
    self.user_type == "admin" ? true : false
  end
  
  def self.find_for_database_authentication(conditions)
    self.where(:login => conditions[:email].downcase).first || self.where(:email => conditions[:email].downcase).first
  end
  
  def create_login  
    if !self.login.nil?
      login_taken = User.where( :login => email[0]).first
      unless login_taken
        self.login = login
      else	
        self.login = self.email
      end	       
    else
      email = self.email.split(/@/)
      login_taken = User.where( :login => email[0]).first
      unless login_taken
        self.login = email[0]
      else	
        self.login = self.email
      end	
    end       
  end
  
  
end

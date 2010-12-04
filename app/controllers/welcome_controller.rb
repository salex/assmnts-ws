class WelcomeController < ApplicationController
  def index
    if !user_signed_in?
      User.find(1).send_confirmation_instructions 
      
    end
  end
end

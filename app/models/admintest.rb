class Admintest
  attr_accessor :current_user, :params
  
  
  def classtest(input = "")
    return "return from x.classtest input -> #{input} from user #{self.current_user.name_full}"
  end
  def self.test(input = "")
    return "return from Assmnt.test input -> #{input}"
  end
  
  class Conv 
    
    def self.xxx(input = "")
      return "return from Assmnt::Conv.xxx input -> #{input} "
    end
    
  end
end
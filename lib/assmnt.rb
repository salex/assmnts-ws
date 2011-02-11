module Assmnt
  def a4d_host
    return "http://192.211.32.248:8010/"
  end
  
  def a4d_fcurl(fdata, ws_path, params=false)
    if params
      result =  %x[curl --form-string  'params=#{fdata}' '#{a4d_host}#{ws_path}']
    else
      result =  %x[curl --form-string  'fdata=#{fdata}' '#{a4d_host}#{ws_path}']
    end
  end
  
  def a4d_qcurl(ws_path)
    result =  %x[curl '#{a4d_host}#{ws_path}']
  end
  
end

class String < Object
=begin 
      I got tired of trying to use gsub, reqexp, downcase, etc to see if 
      something was in a list of words. Maybe there is already something
      out there, but wrote my own
      in console (or put in lib)
      
      status = "progressed"
      status.in?("Dropped Completed Failed Progressed")
=end
  def in?(list,down=true)
    me =  down ? self.downcase : self
    list = list.downcase if down
    inarray = list.split
    return inarray.include?(me)
  end
end

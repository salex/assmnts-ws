class Export < ActiveRecord::Base
  
  def self.getwork
    work = self.where(:status => "New").first
    if work
      work.status = "Sent"
      work.sent = Time.now
      work.save
    end
    return work
  end
  
  def self.didwork(result)
    reply = ActiveSupport::JSON.decode(result)
    
    work = self.where(:token => reply["jobstage"]["export.token"]).first
    if work
      status = reply["jobstage"]["result"]
      if status == "Error"
        work.status = "Error"
        #TODO need a log or email saying there was error with export
      else
        work.status = "Completed"
        jobstage_id = reply["jobstage"]["jobstage_id"]
        responses = reply["jobstage"]["responses"]
        responses.each do |response|
          if response["citizen"]["action"] == "create"
            user = Applicant.find(response["citizen"]["applicant_id"]).user
            user.citizen_id = response["citizen"]["citizen_id"]
            user.save
          end
        end
      end
      work.received = Time.now
      work.response = result
      work.save
    end
  end
  
end

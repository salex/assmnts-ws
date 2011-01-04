class Assessment < ActiveRecord::Base
  has_many :questions, :order => "sequence", :dependent => :destroy
  has_many :assessors
    
  def assessor_count
    assessors.count
  end
  
  def can_modify?
    active_count = self.assessors.where("assessors.status" => "Active").count
    (active_count == 0) && (status != "Master")
  end
  
  def get_status
    return {:can_modify? => self.can_modify?, :status => self.status}
  end
  def self.search(search)  
    if search  
      where('name LIKE ?', "%#{search}%")  
    else  
      order(:id).scoped  
    end  
  end  
#  ans = Answer.select("answers.id").select('answers.xml_key').joins(:question => :assessment).where("questions.id = answers.question_id AND assessments.id = #{aids[0]}")
#  ques = Question.select("questions.id").select('questions.xml_key').joins(:assessment).where("questions.assessment_id = #{aids[0]}")
  def getQandA
    questions = Question.where(:assessment_id => self.id).select("id,question,shortname,minimum_value,critical,weight,score_method,answer_type,xml_key")
    q_ids = questions.map(&:id)  # shorthand for @questions.map{|i| i.id}, which gets array of ids
    answers = Answer.where(:question_id => q_ids).select("id,master_id,answer,shortname,answer_eval,value,question_id,xml_key")
    #ans = Answer.joins(:question => :assessment).where("questions.id = answers.question_id AND assessments.id = 133")*
    a_ids = answers.map(&:id)
    return {:questions => questions ,:q_ids => q_ids, :answers => answers, :a_ids => a_ids}
  end
  
  def  scoreAssessment(params)
    qa = getQandA
    totalScore = 0
    totalScoreWeighted = 0
    category = self.category
    all_answers = []
    all_keys = []
    failed = []
    question_raw = {}
    akeys = qa[:answers].map(&:xml_key)
    akeys.collect! {|k| k.gsub("_","").delete(k.slice(1..1))}
    params["post.answer"].each { |key, value| # key = question.id, value = arrary of answer_id and, if text, text value
      queIDX = qa[:q_ids].index(key.to_i)
      if queIDX.blank?
        next
      end
      queID = qa[:q_ids][queIDX]
      isArray = value.kind_of? Array
      weight = qa[:questions][queIDX][:weight].nil? ? 0 :qa[:questions][queIDX][:weight]
      ansType = qa[:questions][queIDX][:answer_type].blank? ? "" : qa[:questions][queIDX][:answer_type].downcase
      scoreMethod = qa[:questions][queIDX][:score_method].blank? ? "value" : qa[:questions][queIDX][:score_method].downcase
      isScored = ((scoreMethod.downcase != "none")) 
      isText =  !(ansType =~ /text/i).nil?
      
      max = -999
      sum = 0
      if isText
        # Text is always an array and only scored if there is answer_eval
        #
        # This is the first type of answer
        val = 0
        0.step(value.length-1,2) { |i|
          ansID = value[i].to_i
          ansText = value[i+1]
          all_answers << ansID
          ansIDX = qa[:a_ids].index(ansID) 
          if ansIDX.blank?
            next
          end
          all_keys << akeys[ansIDX]
          isTextScored =  !qa[:answers][ansIDX][:answer_eval].blank? 
          if isTextScored and isScored
            val = scoreText(qa[:answers][ansIDX][:value],qa[:answers][ansIDX][:answer_eval],ansText,ansType) if !ansText.blank?
          end
          sum += val
          if( val > max)
            max = val
          end
          #logger.info "The value is #{val} for #{queID.to_s} sum #{sum} max #{max}"
          
        }
      elsif isArray
        # Arrays should only be available for checkbox and select-multiple, but 
        #
        # This is the this second type of answer
        
        for i in 0..value.length-1
          ansID = value[i].to_i
          all_answers << ansID
          ansIDX = qa[:a_ids].index(ansID) 
          if ansIDX.blank?
            next
          end
          all_keys << akeys[ansIDX]
          if (isScored)
            val = qa[:answers][ansIDX][:value].to_f
          else
            val = 0
          end 
          sum += val
          if( val > max)
            max = val
          end
          
        end
      else
        # currently not used, but might change radio to not an array
        #
        # This is the third type of answer
        
        ansID = value.to_i
        all_answers << ansID
        ansIDX = qa[:a_ids].index(ansID) 
        if ansIDX.blank?
          next
        end
        all_keys << akeys[ansIDX]
        if (isScored)
          val = qa[:answers][ansIDX][:value]
        else
          val = 0
        end 
      end
      # The three type of answers only porduce val
      
      if (isArray)
        if ((scoreMethod.downcase == "sum")) 
          answerValue = sum
        else
          answerValue = max
        end
      else
        answerValue = max
      end
      answerValue = 0 if answerValue == -999
      question_raw[queID.to_s] = answerValue
      answerValueWeighted = answerValue * weight
      totalScore += answerValue
      totalScoreWeighted += answerValueWeighted
      if (qa[:questions][queIDX][:critical])
        
        if (answerValue < qa[:questions][queIDX][:minimum_value].to_f)
          failed << qa[:questions][queIDX][:id]
        end
      end
    }
    max_weighted = self.max_weighted.to_f
    max_raw = self.max_raw.to_f
    
    score_raw = 0
    score_weighted = 0
    if max_raw > 0
      score_raw = (totalScore / max_raw) * 100 
    end
    if  max_weighted > 0
      score_weighted =  (totalScoreWeighted / max_weighted) * 100 
    end
    #logger.info "The score values are #{score_raw} and #{score_weighted}"

    score = {"answers" => params["post.answer"],
      "all_answers" => all_answers,
      "all_keys" => all_keys,
      "failed" => failed, 
      "answers_other" => params["post.answer_other"].nil? ? {} : params["post.answer_other"],
      "question_raw" => question_raw,
      "total_raw" => totalScore,
      "total_weighted" => totalScoreWeighted,
      "category" => category,
      "max_raw" => max_raw,
      "max_weighted" => max_weighted,
      "score_weighted" => score_weighted,
      "score_raw" => score_raw,
      "assessment_id" => self.id}
    return score
  end 
  
  private
  
end

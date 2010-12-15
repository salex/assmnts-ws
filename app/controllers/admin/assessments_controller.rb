module Admin
  class AssessmentsController < BaseController
  
    # GET /assessments
    # GET /assessments.xml
    def index
      @assessments = Assessment.search(params[:search]).order(:name,:id).paginate(:per_page => 20, :page => params[:page])

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @assessments }
      end
    end

    # GET /assessments/1
    # GET /assessments/1.xml
    def show
      @assessment = Assessment.find(params[:id])
      @questions = @assessment.questions
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @assessment }
      end
    end

    # GET /assessments/new
    # GET /assessments/new.xml
    def new
      @assessment = Assessment.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @assessment }
      end
    end

    # GET /assessments/1/edit
    def edit
      @assessment = Assessment.find(params[:id])
    end

    # POST /assessments
    # POST /assessments.xml
    def create
      @assessment = Assessment.new(params[:assessment])

      respond_to do |format|
        if @assessment.save
          format.html { redirect_to(admin_assessment_path(@assessment), :notice => 'Assessment was successfully created.') }
          format.xml  { render :xml => @assessment, :status => :created, :location => @assessment }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @assessment.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /assessments/1
    # PUT /assessments/1.xml
    def update
      @assessment = Assessment.find(params[:id])

      respond_to do |format|
        if @assessment.update_attributes(params[:assessment])
          format.html { redirect_to(admin_assessment_path(@assessment), :notice => 'Assessment was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @assessment.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /assessments/1
    # DELETE /assessments/1.xml
    def destroy
      @assessment = Assessment.find(params[:id])
      @assessment.destroy

      respond_to do |format|
        format.html { redirect_to(admin_assessments_url) }
        format.xml  { head :ok }
      end
    end
  
    def display
      @assessment = Assessment.find(params[:id])
      if !session["post-#{params[:id]}"].nil?
        params[:post] =session["post-#{params[:id]}"]
      end
    end
  
    def clone
      @assessment = Assessment.find(params["id"])
      @questions = @assessment.questions
    
      newassessment = @assessment.clone
      if @assessment.master_id == 0
        newassessment.master_id = @assessment.id
      end
      newassessment.save
      newassid = newassessment.id
      for question in @questions
        @answers = question.answers
        newques = question.clone
        newques.assessment_id = newassid
        if question.master_id == 0
          newques.master_id = question.id
        end
        newques.save
        newquesid = newques.id
        for answer in @answers
          newans = answer.clone
          newans.question_id = newquesid
          if answer.master_id == 0
            newans.master_id = answer.id
          end
          newans.save
        end
      end
      flash[:notice] = "Successfully cloned assessment with id: "+ newassid.to_s
      redirect_to admin_assessment_path(newassessment)
    
    end
  
    def post
      @assessment = Assessment.find(params[:id])
      result = @assessment.scoreAssessment(params)
      session["post-#{params[:id]}"] = result
      qa = @assessment.getQandA
    
      #testing dumping post
      @html = dumpPost(result,qa)
      #@json = result.to_json
    end
  
    def json_parse(json)
      return ActiveSupport::JSON.decode(json)
    end
  
   end
 end

module Admin
  class QuestionsController < BaseController

    before_filter :get_question, :except => [:index, :new, :create, :edit]

    # GET /questions
    # GET /questions.xml
    def index
      @questions = Assessment.find(params[:assessment_id]).questions
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @questions }
      end
    end

    # GET /questions/1
    # GET /questions/1.xml
    def show
      #@question = Question.find(params[:id])
      @status = @question.assessment.get_status
      #@answers = @question.answers
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @question }
      end
    end

    # GET /questions/new
    # GET /questions/new.xml
    def new
      @assessment = Assessment.find(params[:assessment_id])
      @question = Question.new
      setNewDefaults

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @question }
      end
    end

    # GET /questions/1/edit
    def edit
      @question = Question.find(params[:id])
    end

    # POST /questions
    # POST /questions.xml
    def create
      @question = Question.new(params[:question])
      @question.assessment_id = params[:assessment_id]
      respond_to do |format|
        if @question.save
          format.html { redirect_to(admin_question_path(@question), :notice => 'Question was successfully created.') }
          format.xml  { render :xml => @question, :status => :created, :location => @question }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /questions/1
    # PUT /questions/1.xml
    def update
      #@question = Question.find(params[:id])

      respond_to do |format|
        if @question.update_attributes(params[:question])
          format.html { redirect_to(admin_assessment_path(@question.assessment_id), :notice => 'Question was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /questions/1
    # DELETE /questions/1.xml
    def destroy
      #@question = Question.find(params[:id])
      @question.destroy

      respond_to do |format|
        format.html { redirect_to(admin_assessment_path(@question.assessment_id)) }
        format.xml  { head :ok }
      end
    end
  
    private
    def setNewDefaults
      max = @assessment.questions.maximum(:sequence) 
      @question.sequence = max.nil? ? 1  : max + 1
      @question.answer_type = @assessment.answer_type.blank? ? "" : @assessment.answer_type
      @question.display_type = @assessment.display_type.blank? ? "" : @assessment.display_type
      @question.assessment_id = @assessment.id
    end
  
    def get_question
      if params[:id]
        @question = Question.find(params[:id])
        @assessment = @question.assessment
      end
    end
  end
end

class AssessorsController < ApplicationController
  # GET /assessors
  # GET /assessors.xml
  def index
    #@assessors = Assessor.includes(:assessment).order("assessed_model, assessing_type, sequence")
    @assessors = Assessor.where(:assessing_id => params[:stage_id]).includes(:assessment).order("assessed_model, assessing_type, sequence")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assessors }
      format.js 
    end
  end

  # GET /assessors/1
  # GET /assessors/1.xml
  def show
    @assessor = Assessor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @assessor }
    end
  end

  # GET /assessors/new
  # GET /assessors/new.xml
  def new
    @assessor = Assessor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @assessor }
    end
  end

  # GET /assessors/1/edit
  def edit
    @assessor = Assessor.find(params[:id])
  end

  # POST /assessors
  # POST /assessors.xml
  def create
    @assessor = Assessor.new(params[:assessor])

    respond_to do |format|
      if @assessor.save
        format.html { redirect_to(@assessor, :notice => 'Assessor was successfully created.') }
        format.xml  { render :xml => @assessor, :status => :created, :location => @assessor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @assessor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /assessors/1
  # PUT /assessors/1.xml
  def update
    @assessor = Assessor.find(params[:id])

    respond_to do |format|
      if @assessor.update_attributes(params[:assessor])
        format.html { redirect_to(@assessor.assessing, :notice => 'Assessor was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @assessor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assessors/1
  # DELETE /assessors/1.xml
  def destroy
    @assessor = Assessor.find(params[:id])
    @assessor.destroy

    respond_to do |format|
      format.html { redirect_to(assessors_admin_dba_index_path) }
      format.xml  { head :ok }
    end
  end
  
  def display
    @assessor = Assessor.find(params[:id])
    #@assessment = Assessment.find(@assessor.assessment_id)
    @score = Score.get_or_create_score(@assessor,params)
    if !@score.score_object.blank?
      params[:post] = json_parse(@score.score_object)
    end
    render :template => "assessors/display"
  end
  
  def post
    @assessor = Assessor.find(params[:id])
    @assessment = Assessment.find(@assessor.assessment_id)
    @score = Score.find(params[:model_id])
    result = @assessment.scoreAssessment(params)
    @score.score_object = result.to_json
    @score.status = "complete"
    @score.score =  result[:score_raw]
    @score.save
    #session["post-#{params[:id]}"] = result
    #testing dumping post
    @html = dumpPost(result,@assessment.getQandA)
    render :template => "assessors/post"
    
  end
  def json_parse(json)
    return ActiveSupport::JSON.decode(json)
  end
  
end

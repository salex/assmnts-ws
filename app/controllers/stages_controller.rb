class StagesController < ApplicationController
  # GET /stages
  # GET /stages.xml
  load_and_authorize_resource
  def index
    @stages = Stage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stages }
    end
  end

  # GET /stages/1
  # GET /stages/1.xml
  def show
    #@stage = Stage.find(params[:id])
    @assessors = @stage.assessors
    @ass = Assessment.search("job."+@stage.job_id.to_s)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stage }
    end
  end
  
  def import
    @stage = Stage.find(params[:id])
    assmnt =  %x[curl --form-string  'fdata=#{@stage[:jobstage_id]}' 'http://localhost:8080/ws.jobstage.get_xml_assmnt']
    @stage["assessment_json"] = assmnt
    @stage.save
    
    render "stages/show"
  end

  # GET /stages/new
  # GET /stages/new.xml
  def new
    @stage = Stage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stage }
    end
  end

  # GET /stages/1/edit
  def edit
    #@stage = Stage.find(params[:id])
  end

  # POST /stages
  # POST /stages.xml
  def create
    @stage = Stage.new(params[:stage])

    respond_to do |format|
      if @stage.save
        format.html { redirect_to(@stage, :notice => 'Stage was successfully created.') }
        format.xml  { render :xml => @stage, :status => :created, :location => @stage }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stages/1
  # PUT /stages/1.xml
  def update
    #@stage = Stage.find(params[:id])

    respond_to do |format|
      if @stage.update_attributes(params[:stage])
        format.html { redirect_to(@stage, :notice => 'Stage was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stages/1
  # DELETE /stages/1.xml
  def destroy
    #@stage = Stage.find(params[:id])
    @stage.destroy

    respond_to do |format|
      format.html { redirect_to(stages_url) }
      format.xml  { head :ok }
    end
  end
  
  def applicants
    #@stage = Stage.find(params[:id])
    @applicants = @stage.applicants.order("weighted DESC").paginate(:per_page => 20, :page => params[:page])
    respond_to do |format|
      format.html {render :template => "stages/_applicants"}
      
      format.xml  { render :xml => @stage }
      format.js
    end
  end
  
  def assessors
    @stage = Stage.find(params[:id])
    @assessors = @stage.assessors
    respond_to do |format|
      format.html {render :template => "stages/_assessors"}
      
      format.xml  { render :xml => @stage }
      format.js
    end
  end
  
  
  def details
    render :text => "hi details"
  end
  
  def rescore
    @stage = Stage.find(params[:id])
    @stage.rescore
    redirect_to @stage
    
  end
  
end

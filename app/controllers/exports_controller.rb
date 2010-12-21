class ExportsController < ApplicationController
  # GET /exports
  # GET /exports.xml
  def index
    @exports = Export.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exports }
    end
  end

  # GET /exports/1
  # GET /exports/1.xml
  def show
    @export = Export.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @export }
    end
  end

  # GET /exports/new
  # GET /exports/new.xml
  def new
    @export = Export.new
    @export.token =  Devise.friendly_token
    @export.user_id = current_user.id
    @export.status = "New"
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @export }
    end
  end

  # GET /exports/1/edit
  def edit
    @export = Export.find(params[:id])
  end

  # POST /exports
  # POST /exports.xml
  def create
    @export = Export.new(params[:export])

    respond_to do |format|
      if @export.save
        format.html { redirect_to(@export, :notice => 'Export was successfully created.') }
        format.xml  { render :xml => @export, :status => :created, :location => @export }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @export.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exports/1
  # PUT /exports/1.xml
  def update
    @export = Export.find(params[:id])

    respond_to do |format|
      if @export.update_attributes(params[:export])
        format.html { redirect_to(@export, :notice => 'Export was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @export.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exports/1
  # DELETE /exports/1.xml
  def destroy
    @export = Export.find(params[:id])
    @export.destroy

    respond_to do |format|
      format.html { redirect_to(exports_url) }
      format.xml  { head :ok }
    end
  end
end

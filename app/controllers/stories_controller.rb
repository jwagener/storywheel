class StoriesController < ApplicationController
  # GET /stories
  # GET /stories.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    if params[:track].blank?
      redirect_to root_url
    else
      sc = Soundcloud.new(:client_id => "YOUR_CLIENT_ID")
      permalink = "#{params[:user]}/#{params[:track]}"
      @track    = cache_store.fetch permalink do
        logger.info "SC GET: #{permalink}"
        sc.get("/resolve", :url => "http://soundcloud.com/#{permalink}")
      end
      @comments = cache_store.fetch "#{permalink}/comments"  do
        logger.info "SC GET: #{permalink}/comments"
        sc.get("#{@track.uri}/comments")
      end

      render :template => "stories/index"
    end
  end

  # GET /stories/new
  # GET /stories/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @story }
    end
  end

  # GET /stories/1/edit
  def edit
  end

  # POST /stories
  # POST /stories.json
  def create

    respond_to do |format|
      if @story.save
        format.html { redirect_to @story, notice: 'Story was successfully created.' }
        format.json { render json: @story, status: :created, location: @story }
      else
        format.html { render action: "new" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.json
  def update
    respond_to do |format|
      if @story.update_attributes(params[:story])
        format.html { redirect_to @story, notice: 'Story was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    respond_to do |format|
      format.html { redirect_to stories_url }
      format.json { head :ok }
    end
  end
end

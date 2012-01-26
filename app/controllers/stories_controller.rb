class StoriesController < ApplicationController
  SOCIAL = {
      title: "Story Wheel",
      description: "Tell the story behind your pictures",
      url: "http://storywheel.cc",
      image: "http://storywheel.cc/facebook_2.jpg",
      type: "website",
      twitter: "Check out #StoryWheel"
  }

  before_filter do
    if request.url.include?("http://www")
      redirect_to request.url.gsub("http://www.", "http://")
    end
    false
  end

  before_filter do
    @social = SOCIAL
    @social[:url] = request.url.gsub("localhost:3000", "storywheel.cc")
  end

  # GET /stories.json
  def index
    expires_in 15.minutes, :public => true
    @social = SOCIAL
    respond_to do |format|
      format.html { response.etag = "index" }
      format.json { render json: @stories }
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    expires_in 15.minutes, :public => true

    @social = SOCIAL

    if params[:track].blank?
      redirect_to root_url
    else
      force = false
      sc = Soundcloud.new(:client_id => "YOUR_CLIENT_ID")
      permalink = "#{params[:user]}/#{params[:track]}"
      @track    = cache_store.fetch permalink, :force => force do
        logger.info "SC GET: #{permalink}"
        sc.get("/resolve", :url => "http://soundcloud.com/#{permalink}")
      end
      @comments = cache_store.fetch "#{permalink}/comments", :force => force do
        logger.info "SC GET: #{permalink}/comments"
        sc.get("#{@track.uri}/comments", :limit => 200)
      end.sort_by(&:timestamp)      
      @social[:title] = "#{@track.title} by #{@track.user.username}"
      @social[:description] = "Story Wheel - Tell the story behind your pictures"
      @social[:type] = "article"
      @social[:twitter] = "Listen to #{@social[:title]} on #StoryWheel"
      response.etag = permalink
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

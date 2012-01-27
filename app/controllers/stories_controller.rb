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
      @options = optionsFromTagList(@track.tag_list)
      @social[:image] = @options[:image] if @options[:image]
      @social[:title] = "#{@track.title} by #{@track.user.username}"
      @social[:description] = "Story Wheel - Tell the story behind your pictures"
      @social[:type] = "article"
      @social[:twitter] = "Listen to #{@social[:title]} on #StoryWheel"

      response.etag = permalink
      render :template => "stories/index"
    end

  rescue Soundcloud::ResponseError => e
    raise ActiveRecord::RecordNotFound
  end

private

  def optionsFromTagList(tag_list)
    options = tag_list.split(" ").inject({}) do |obj, tag|
      if m = tag.match(/:(.*)=(.*)/)
        obj[m[1]] = m[2]
      end
      obj
    end
    HashWithIndifferentAccess.new(options)
  end
end

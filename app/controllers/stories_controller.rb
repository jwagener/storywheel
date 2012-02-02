class StoriesController < ApplicationController
  DEFAULT_OPTIONS = {
    soundcloudClientId:    Rails.env == "production" ? "732fa8e77cc2fe02a4a9edfe5f76135d"  : "3a57e26203bc5210285a02f8eee95d91",
    soundcloudRedirectUri: Rails.env == "production" ? "http://storywheel.cc/callback.htm" : "http://localhost:3000/callback.html",
    soundcloudGroupId:     63665, # official one is 63307
    slideClickTrackId:     27266065,
    demoTracks:            ["http://storywheel.cc/tengoogs/things", "http://storywheel.cc/steve-mays/a-story", "http://storywheel.cc/patrickjonespoet/poppysky", "http://storywheel.cc/tracyshaun/dreaming", "http://storywheel.cc/rogerforlovers/the-boy-the-sea",  "http://storywheel.cc/im2b/my-home", "http://storywheel.cc/hankus/my-new-friend", "http://storywheel.cc/cobedy/jeordie-mcevens"],
    demo:                  false,
    slideSound:            true,
    autoplay:              false,
    backgroundVolume:      25
    # other options:
    #backgroundTrackId # background Music
    #image # primary image in preview
    #backgroundImage:       "" # not yet implemented, set manual background image
  }

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
      @options = DEFAULT_OPTIONS.merge optionsFromTagList(@track.tag_list)
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

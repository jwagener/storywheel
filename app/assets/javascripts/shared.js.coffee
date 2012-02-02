window.SW =
  instagramToken: null
  instagramPopup: null
  backgroundTrackSound: null
  foregroundTrackSound: null
  slideSound: null
  slides: []
  options: {}
  
  initialize: (options)->
    SW.options = options
    SC.initialize 
      client_id:    SW.options.soundcloudClientId
      redirect_uri: SW.options.soundcloudRedirectUri
      
    SW.parseFragmentOptions()
    if SW.options.demo
      $("body").addClass("demo")

    if SW.getState() == "home"
      SW.loadAllStories(0)
    
    if SW.getState() == "show"
      SW.preparePlay()

  showImage: (imageUrl) ->
    $("#currentImage").css("background-image", "url("+imageUrl+")")

  getState: ->
    $("body").attr("id")

  setState: (state) ->
    states = ["home", "connect", "pick", "prerecord", "record", "finalize", "upload", "show", "play"]
    $("body").attr("id", state)

  loadSlideClick: () ->
    SW.slideSound = SC.stream SW.options.slideTrackId, autoLoad: true
    
  playSlideClick: () ->
    SW.slideSound.play()

  preparePlay: () ->
    if SW.options.autoplay
      SW.setState("play")
    limit = 50
    offset = 0
    commentsByTimestamp = {}
    SW.addComments = ->
      for comment in comments
        if comment.user_id == track.user_id && comment.body.match(/storywheel.(com|cc)/)
          (->
            imageUrl = SW.Helpers.imageUrlFromComment(comment)
            $("<img src='" + imageUrl + "' />").appendTo("#preload")
            SW.showImage(imageUrl) if comment.timestamp == 0
            co = comment
            SW.foregroundTrackSound.onposition comment.timestamp, () ->
              SW.showImage(imageUrl)
              if this.timestamp > 0 && SW.options.slideSound
                SW.playSlideClick()
            , comment
          )()
      if SW.options.autoplay
        SW.play()
    SC.whenStreamingReady ->
      SW.foregroundTrackSound = SC.stream window.track.id, autoLoad: true
      if SW.options.backgroundTrackId? && SW.options.backgroundTrackId != ""
        SW.backgroundTrackSound = SC.stream SW.options.backgroundTrackId, {autoLoad: true, volume: SW.options.backgroundVolume }
      SW.loadSlideClick()
      SW.addComments()
      $("#playButton").addClass("ready")

  play: ->
    SW.setState("play")
    SW.foregroundTrackSound.play
      onplay: ->
        SW.backgroundTrackSound.play() if SW.backgroundTrackSound?
      onfinish: ->
        finish = () ->
          SW.showImage(SW.Helpers.imageUrlFromComment(comments[0]))
          if SW.options.demo
            SW.goToNextDemo()
          else
            SW.setState("show")
        if SW.backgroundTrackSound?
          SW.fadeOut SW.backgroundTrackSound, -1, () ->
            finish()
        else
          finish()

  parseFragmentOptions: () ->
    fragmentOptions = new SC.URI(window.location, {decodeFragment: true}).fragment
    if fragmentOptions.demo == "1"
      SW.options.demo = true
    if fragmentOptions.slideSound == "0"
      SW.options.slideSound = false
    if fragmentOptions.autoplay?
      SW.options.autoplay = true

  goToNextDemo: () ->
    index = parseInt(Math.random() * SW.options.demoTracks.length, 10)
    window.location = SW.options.demoTracks[index] + "#autoplay&demo=1"

  updateTimer: (ms) ->
    $("#timer").text(SC.Helper.millisecondsToHMS(ms));

  showNextImageFromSelection: ->
    $img = $("#selection li.image").first()
    images = $("#selection li.image")
    imagesLeft = images.length

    if imagesLeft == 0
      SC.recordStop();
      SW.updateTimer(0);
      SW.setState("finalize")
    else
      $img = images.first()

      SW.showImage($img.attr("data-image-url"))
      SW.slides.push
        imageUrl: $img.attr("data-image-url")
        timestamp: Recorder.flashInterface().recordingDuration()

      $img.remove()
      imagesLeft--
      if imagesLeft == 0
        statusText = "The last picture. Wrap it up!"
      else if imagesLeft == 1
        statusText = "1 picture left."
      else
        statusText = imagesLeft + " pictures left"
    $("#status").html(statusText)

  instagramCallback: () ->
    popupLocation = SW.instagramPopup.location.toString()
    uri = new SC.URI(popupLocation, {decodeQuery: true, decodeFragment: true})
    error = uri.query.error || uri.fragment.error
    SW.instagramPopup.close()

    if error
      throw new Error(uri.query.error)
    else
      SW.instagramToken = uri.fragment.access_token
      SW.setState("pick")
      $.ajax(
        dataType: "JSONP"
        url: "https://api.instagram.com/v1/users/self/media/recent?callback=?&count=48&access_token=" + SW.instagramToken
        success: (r) ->
          $.each r.data, -> 
            image = 
              url: this.images.standard_resolution.url,
              thumbnail_url: this.images.thumbnail.url,
              timestamp: null
            $("#imageTmpl").tmpl(image).appendTo("ul.all-images");
          $("ul.selection").sortable({connectWith: ".all-images"})
          $(".all-images").sortable({connectWith: "ul.selection"})
      )
      
  loadAllStories: (offset) -> 
    SC.get "/groups/" + SW.options.soundcloudGroupId + "/tracks", {"offset": offset}, (tracks) ->
      if tracks.length == 50
        SW.loadAllStories( offset + 50)
      $.each tracks, ->
        track = this
        track.story_url = track.permalink_url.replace("http://soundcloud.com", "")
        if match = track.tag_list.match(/storywheel:image=([^ ]*)/)
          track.artwork_url = match[1].replace("_7", "_5") # I HOPE THIS WORKS FOR ALL PICTURES!
        $("#storyTmpl").tmpl(track).appendTo(".stories ul");

SW.Helpers =
  imageUrlFromComment: (comment) ->
    comment.body.match(/#([^>]*)\>/)[1]
  
  fadeOut: (sound, amount, callback) ->
    vol = sound.volume;
    if !vol
      vol = 0
    if vol == 0
      sound.stop()
      callback()
      return false
    sound.setVolume(Math.max(0,vol+amount));
    setTimeout () -> 
      SW.Helpers.fadeOut sound, amount, callback
    , 200

$ ->
  # window.storywheelOptions provided by rails render
  SW.initialize(window.storywheelOptions)

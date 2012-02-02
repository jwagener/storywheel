window.SW =
  soundcloudCredentials:
    client_id: "3a57e26203bc5210285a02f8eee95d91"
    redirect_uri: "http://localhost:3000/callback.html"

  instagramToken: null
  instagramPopup: null
  soundcloudGroup: "/groups/63665" # official one is 63307
  slideClickTrackId: 27266065
  backgroundTrackIds: [1627453, 33423817, 25780527] #nature of daylight, werd
  backgroundTrack: null
  foregroundTrack: null
  slides: []
  demos: ["http://storywheel.cc/tengoogs/things", "http://storywheel.cc/steve-mays/a-story", "http://storywheel.cc/patrickjonespoet/poppysky", "http://storywheel.cc/tracyshaun/dreaming", "http://storywheel.cc/rogerforlovers/the-boy-the-sea",  "http://storywheel.cc/im2b/my-home", "http://storywheel.cc/hankus/my-new-friend", "http://storywheel.cc/cobedy/jeordie-mcevens"]
  options: 
    slideSound: true
    autoplay:   false
  trackOptions: {}
  
  showImage: (imageUrl) ->
    $("#currentImage").css("background-image", "url("+imageUrl+")")

  setState: (state) ->
    states = ["home", "connect", "pick", "prerecord", "record", "finalize", "upload", "show", "play"]
    $("body").attr("id", state)

  loadSlideClick: () ->
    SW.slideClick = SC.stream SW.slideClickTrackId, autoLoad: true
    
  playSlideClick: () ->
    SW.slideClick.play()

  play: ->
    SW.setState("play")
    SW.foregroundTrack.play
      onplay: ->
        SW.backgroundTrack.play() if SW.backgroundTrack?
      onfinish: ->
        finish = () ->
          SW.showImage(SW.Helpers.imageUrlFromComment(comments[0]))
          if SW.options.demo
            SW.goToNextDemo()
          else
            SW.setState("show")
        if SW.backgroundTrack?
          SW.fadeOut SW.backgroundTrack, -1, () ->
            finish()
        else
          finish()

  parseFragmentOptions: () ->
    SW.fragmentOptions = new SC.URI(window.location, {decodeFragment: true}).fragment
    if SW.fragmentOptions.demo == "1"
      $("body").addClass("demo")
      SW.options.demo = true
    if SW.fragmentOptions.slideSound == "0"
      SW.options.slideSound = false
    if SW.fragmentOptions.autoplay?
      SW.options.autoplay = true

  goToNextDemo: () ->
    index = parseInt(Math.random() * SW.demos.length, 10)
    window.location = SW.demos[index] + "#autoplay&demo=1"

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

if window.location.host != "localhost:3000"
  SW.soundcloudCredentials = 
    client_id: "732fa8e77cc2fe02a4a9edfe5f76135d"
    redirect_uri: "http://storywheel.cc/callback.html"

SC.initialize(SW.soundcloudCredentials)
SW.parseFragmentOptions()


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
      SW.fadeOut sound, amount, callback
    , 200
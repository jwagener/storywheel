window.SETTINGS = 
  soundcloud:
    client_id: "3a57e26203bc5210285a02f8eee95d91"
    redirect_uri: "http://localhost:3000/callback.html"
  soundcloudGroup: "/groups/63665" # official one is 63307
  slideClickTrackId: 27266065
  backgroundTrackIds: [1627453, 33423817, 25780527] #nature of daylight, werd

if window.location.host != "localhost:3000"
  SETTINGS.soundcloud = 
    client_id: "732fa8e77cc2fe02a4a9edfe5f76135d"
    redirect_uri: "http://storywheel.cc/callback.html"


window.SW =
  backgroundTrack: null
  foregroundTrack: null
  slides: []
  options: 
    slideSound: true
  
  showImage: (imageUrl) ->
    $("#currentImage").css("background-image", "url("+imageUrl+")")

  setState: (state) ->
    states = ["home", "connect", "pick", "prerecord", "record", "finalize", "upload", "show", "play"]
    $("body").attr("id", state)

  loadSlideClick: () ->
    SW.slideClick = SC.stream SETTINGS.slideClickTrackId, autoLoad: true
    
  playSlideClick: () ->
    SW.slideClick.play()

  play: ->
    SW.setState("play")
    SW.foregroundTrack.play
      onplay: ->
        SW.backgroundTrack.play() if SW.backgroundTrack?
      onfinish: ->
        if SW.backgroundTrack?
          SW.fadeOut SW.backgroundTrack, -1, () ->
            SW.showImage(SW.imageUrlFromComment(comments[0]))
            SW.setState("show")
        else
          SW.showImage(SW.imageUrlFromComment(comments[0]))
          SW.setState("show")
  fadeOut: (s, amount, callback) ->
    vol = s.volume;
    if vol == 0
      s.stop()
      callback()
      return false
    s.setVolume(Math.max(0,vol+amount));
    setTimeout () -> 
      SW.fadeOut s, amount, callback
    , 200

  imageUrlFromComment: (comment) ->
    comment.body.match(/#([^>]*)\>/)[1]

  parseFragmentOptions: () ->
    SW.fragmentOptions = new SC.URI(window.location, {decodeFragment: true}).fragment
    if SW.fragmentOptions.demo == "1"
      $("body").addClass("demo")

    if SW.fragmentOptions.slideSound == "0"
      SW.options.slideSound = false



      

$(".cancel").live "click", (e) ->
  $(this).closest(".reset").addClass("really")
  e.preventDefault()

$(".reset .no").live "click", (e) ->
  $(this).closest(".reset").removeClass("really")
  e.preventDefault()

$(".aboutLink").live "click", (e) ->
  if $("body").attr("id") == "about" && window.oldState
    SW.setState(window.oldState)
  else
    window.oldState = $("body").attr("id")
    SW.setState("about")
  e.preventDefault()

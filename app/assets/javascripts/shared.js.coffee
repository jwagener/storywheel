window.SETTINGS = 
  soundcloud:
    client_id: "3a57e26203bc5210285a02f8eee95d91"
    redirect_uri: "http://localhost:3000/callback.html"
  soundcloudGroup: "/groups/59904"
    
if window.location.host != "localhost:3000"
  SETTINGS.soundcloud = 
    client_id: "732fa8e77cc2fe02a4a9edfe5f76135d"
    redirect_uri: "http://storywheel.cc/callback.html"


window.SW =
  slides: []
  
  showImage: (imageUrl) ->
    $("#currentImage").css("background-image", "url("+imageUrl+")")

  setState: (state) ->
    states = ["home", "connect", "pick", "prerecord", "record", "endrecord", "finalize", "upload", "show", "play"]
    $("body").attr("id", state)
    #$("body").removeClass(s) for s in states
    #$("body").addClass(state)

    
# story -> slides -> {image_large_url, image_small_url, timestamp}
#       -> audio
#       -> background_audio
#
#

$(".cancel").live "click", (e) ->
  $(this).closest(".reset").addClass("really")
  e.preventDefault()

$(".reset .no").live "click", (e) ->
  $(this).closest(".reset").removeClass("really")
  e.preventDefault()

$(".aboutLink").live "click", (e) ->
  SW.setState("about")
  e.preventDefault()

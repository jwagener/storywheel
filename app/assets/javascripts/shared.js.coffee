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
$("#playButton.ready").live "click", (e) ->
  e.preventDefault()
  SW.play()

$(".next").live "click", (e) ->
  newScroll = $(".stories ul").width() + $(".stories ul").scrollLeft()
  $(".stories ul").scrollLeft(newScroll - (newScroll % 110) - 115 )
  e.preventDefault()

$(".prev").live "click", (e) ->
  newScroll = $(".stories ul").width() - $(".stories ul").scrollLeft()
  $(".stories ul").scrollLeft(newScroll + (newScroll % 110) + 115 )
  e.preventDefault()

$(".aboutLink").live "click", (e) ->
  if $("body").attr("id") == "about" && window.oldState
    SW.setState(window.oldState)
  else
    window.oldState = $("body").attr("id")
    SW.setState("about")
  e.preventDefault()

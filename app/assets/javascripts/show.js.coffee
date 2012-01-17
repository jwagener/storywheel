$ ->
  $("body#home").each ->
    SC.get SETTINGS.soundcloudGroup + "/tracks", (tracks) ->
      $.each tracks, ->
        track = this
        track.story_url = track.permalink_url.replace("http://soundcloud.com", "")

        track.artwork_url = track.tag_list.match(/storywheel:image=(.*)/)[1]
        $("#storyTmpl").tmpl(track).appendTo(".stories ul");

$("#playButton").live "click", (e) ->
  e.preventDefault()
  limit = 50
  offset = 0
  commentsByTimestamp = {}
  addCommentsAndPlay = (stream) ->
    #SC.get "/tracks/" + track.id + "/comments", {"limit": limit, "offset": offset}, (comments) -> 

    for comment in comments
      if comment.user_id == track.user_id && comment.body.match(/storywheel.(com|cc)/)
        stream.onposition comment.timestamp, () ->
          url = this.body.match(/#([^>]*)\>/)[1]
          SW.showImage(url)
          if this.timestamp > 0
            SW.playSlideClick()
        , comment
    if comments.length >= limit
      offset += limit
      addCommentsAndPlay(stream)
    else
      SW.setState("play")
      stream.play()

        
  SC.whenStreamingReady ->
    stream = SC.stream track.id, {autoLoad: true}

    SW.loadSlideClick()
    addCommentsAndPlay(stream)
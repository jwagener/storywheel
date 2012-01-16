$ ->
  $("body#home").each ->
    SC.get SETTINGS.soundcloudGroup + "/tracks", (tracks) ->
      $.each tracks, ->
        track = this
        track.story_url = track.permalink_url.replace("http://soundcloud.com", "")
        $("#storyTmpl").tmpl(track).appendTo(".stories ul");

$("#play").live "click", (e) ->
  e.preventDefault()
  limit = 50
  offset = 0
  commentsByTimestamp = {}
  addCommentsAndPlay = (stream) ->
    console.log stream
    SC.get "/tracks/" + track.id + "/comments", {"limit": limit, "offset": offset}, (comments) -> 
      for comment in comments
        if comment.user_id == track.user_id && comment.body.match(/storywheel.com/)
          stream.onposition comment.timestamp, () ->
            url = this.body.match(/#([^>]*)\>/)[1]
            console.log(url)
            SW.showImage(url)
          , comment
      if comments.length >= limit
        offset += limit
        addCommentsAndPlay(stream)
      else
        SW.setState("play")
        stream.play()

        
  SC.whenStreamingReady ->
    stream = SC.stream track.id, {autoLoad: true}
    addCommentsAndPlay(stream)
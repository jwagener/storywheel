$ ->
  $("body#home").each ->
    SC.get SETTINGS.soundcloudGroup + "/tracks", (tracks) ->
      $.each tracks, ->
        track = this
        track.story_url = track.permalink_url.replace("http://soundcloud.com", "")
        track.artwork_url = track.tag_list.match(/storywheel:image=([^ ]*)/)[1]
        $("#storyTmpl").tmpl(track).appendTo(".stories ul");



  $("body#show").each ->
    limit = 50
    offset = 0
    commentsByTimestamp = {}
    SW.addComments = ->
      for comment in comments
        if comment.user_id == track.user_id && comment.body.match(/storywheel.(com|cc)/)
          (->
            $("<img src='" + imageUrl + "' />").appendTo("#preload")
            imageUrl = comment.body.match(/#([^>]*)\>/)[1]
            SW.showImage(imageUrl) if comment.timestamp == 0
            SW.foregroundTrack.onposition comment.timestamp, () ->
              SW.showImage(imageUrl)
              if this.timestamp > 0
                SW.playSlideClick()
            , comment
          )()
      if comments.length >= limit
        offset += limit
        SW.addComments()
      else
        #console.log('ready to play')
        #SW.play()

    SC.whenStreamingReady ->
      SW.foregroundTrack = SC.stream track.id, autoLoad: true
      if matchData = track.tag_list.match(/storywheel:backgroundTrackId=([^ ]*)/)
        SW.backgroundTrack = SC.stream matchData[1], {autoLoad: true, volume: 25}
      SW.loadSlideClick()
      SW.addComments()


$("#playButton").live "click", (e) ->
  e.preventDefault()

  SW.play()


        

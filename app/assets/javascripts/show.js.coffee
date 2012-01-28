$ ->
  SW.parseFragmentOptions()

  $("body#home").each ->
    loadStories = (offset) -> 
      SC.get SETTINGS.soundcloudGroup + "/tracks", {"offset": offset}, (tracks) ->
        if tracks.length == 50
          loadStories( offset + 50)
        $.each tracks, ->
          track = this
          track.story_url = track.permalink_url.replace("http://soundcloud.com", "")
          if match = track.tag_list.match(/storywheel:image=([^ ]*)/)
            track.artwork_url = match[1].replace("_7", "_5") # I HOPE THIS WORKS FOR ALL PICTURES!
          $("#storyTmpl").tmpl(track).appendTo(".stories ul");
    loadStories(0)
    


  $("body#show").each ->
    if SW.options.autoplay
      SW.setState("play")
    limit = 50
    offset = 0
    commentsByTimestamp = {}
    SW.addComments = ->
      for comment in comments
        if comment.user_id == track.user_id && comment.body.match(/storywheel.(com|cc)/)
          (->
            imageUrl = SW.imageUrlFromComment(comment)
            $("<img src='" + imageUrl + "' />").appendTo("#preload")
            SW.showImage(imageUrl) if comment.timestamp == 0
            co = comment
            SW.foregroundTrack.onposition comment.timestamp, () ->
              SW.showImage(imageUrl)
              if this.timestamp > 0 && SW.options.slideSound
                SW.playSlideClick()
            , comment
          )()
      if SW.options.autoplay
        SW.play()
    SC.whenStreamingReady ->
      SW.foregroundTrack = SC.stream track.id, autoLoad: true
      if SW.trackOptions.backgroundTrackId?
        SW.backgroundTrack = SC.stream SW.trackOptions.backgroundTrackId, {autoLoad: true, volume: SW.trackOptions.backgroundVolume || 25 }
      SW.loadSlideClick()
      SW.addComments()
      $("#playButton").addClass("ready")


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

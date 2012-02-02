$(".build-your-own").live "click", (e) ->
  SW.setState("connect")
  e.preventDefault()

$("ul.all-images li").live "click", (e) ->
  empties = $("ul.selection li.empty")
  if empties.length < 2
    empties.first().clone().appendTo("ul.selection")
  empties.first().replaceWith($(this))

$(".goToStep2").live "click", (e) ->
  if $("ul.selection li.image").length > -1
    $("ul.selection li.image").appendTo("ul.step2-selection");
  else
    alert("Pick some photos first")
  SW.setState("prerecord")
  e.preventDefault()

$(window).keyup (e) ->
  if e.keyCode == 32 && $("body#record").length > 0
    SW.showNextImageFromSelection()
    e.preventDefault()

$("#recordStatus").live "click", (e) ->
  SW.showNextImageFromSelection()
  e.preventDefault()

$(".startRecording").live "click", (e) -> 
  SW.updateTimer(0);  
  SC.record
    start: () ->
      SW.setState("record")
      SW.showNextImageFromSelection()
  
    progress: (ms, avgPeak) ->
      SW.updateTimer(ms);
  e.preventDefault()

$("#goToStep3").live "click", (e) ->
  e.preventDefault()
  
$("#uploadButton").live "click", (e) ->
  SC.options.site = "soundcloud.com" # TODO remove
  e.preventDefault()
  SC.connect
    connected: ->
      title = $("#title").val()
      title = "A story" if title == ""
      tags = []
      tags.push("storywheel:image=" + SW.slides[0].imageUrl) # TODO use 150_150
      tags.push("storywheel:backgroundTrackId=" + ($("#backgroundTrackId").val() || ""));
      
      options =
        track: 
          title: title
          tag_list: tags.join(" ") 
          shared_to: {connections: [no: 0]}
      SW.setState("upload")
      $(".progress #wheel", window).addClass("rotate")
      $("#progressMessage").text("Uploading...")
      SC.recordUpload options, (track) -> 
        $("#progressMessage").text("Processing...")

        storyUrl = "http://storywheel.cc/" + track.user.permalink + "/" + track.permalink
        # update description with link to carousel
        # create comments
        i = 0
        $.each SW.slides, ->
          slide = this
          i++
          body = "<a href=" + storyUrl + "#" + slide.imageUrl + ">StoryWheel Picture #" + i + "</a>"
          SC.post track.uri + "/comments", {
            comment: {
              body: body,
              timestamp: slide.timestamp
            }
          }, (comment) ->
            # ignore
        
        SC.put SW.soundcloudGroup + "/contributions/" + track.id, (contribution) ->
          #contributed
        
        checkState = -> 
          SC.get track.uri, (track) -> 
            if track.state == "finished"
              window.location = track.permalink_url.replace("soundcloud.com", window.location.host)
            else
              window.setTimeout(checkState, 2000)
        window.setTimeout(checkState, 2000)    
    
$(".connectInstagram").live 'click', (e) ->
  e.preventDefault()
  instagramUrl = "/connect-instagram"
  SW.instagramPopup = SC.Helper.openCenteredPopup(instagramUrl, 1024, 370)

$(".cancel").live "click", (e) ->
  $(this).closest(".reset").addClass("really")
  e.preventDefault()

$(".reset .no").live "click", (e) ->
  $(this).closest(".reset").removeClass("really")
  e.preventDefault()
    
    
    
    
    
    
    
    
    
    
    

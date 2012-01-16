# Story Creation

# Load Instagram Pictures

slides = []
window.recordingPosition = 0

SETTINGS = 
  soundcloud:
    client_id: "3a57e26203bc5210285a02f8eee95d91"
    redirect_uri: "http://localhost:3000/callback.html"
  soundcloudGroup: "/groups/59904"
    
if window.location.host != "localhost:3000"
  SETTINGS.soundcloud = 
    client_id: "732fa8e77cc2fe02a4a9edfe5f76135d"
    redirect_uri: "http://storywheel.cc/callback.html"
    
  

$ ->
  SC.initialize(SETTINGS.soundcloud)
  
  
  uri = new SC.URI(window.location.toString(), {decodeFragment: true});
  accessToken = uri.fragment.access_token;
   

$("#createYourOwn").live "click", (e) ->
  SW.setState("connect")
  e.preventDefault()


# List UI
$("ul.all-images li").live "click", (e) ->
  
  empties = $("ul.selection li.empty")
  if empties.length < 2
    empties.first().clone().appendTo("ul.selection")
    $("#selection").scrollLeft(100000)
  empties.first().replaceWith($(this))


# Second step

showNextImage = ->
  $img = $("#selection li.image").first()
  SW.showImage($img.attr("data-image-url"))
  slides.push
    imageUrl: $img.attr("data-image-url")
    timestamp: Recorder.flashInterface().recordingDuration()

  $img.remove()
  if $("#selection li.image").length == 0
    SW.setState("endrecord")




$(".goToStep2").live "click", (e) ->
  if $("ul.selection li.image").length > -1
    $("ul.selection li.image").appendTo("ul.step2-selection");
    $("<li class='empty fin'><span>Fin</span></li>").appendTo("ul.step2-selection");
  else
    alert("Pick some photos first")
  SW.setState("prerecord")
  e.preventDefault()


$("#nextPicture").live "click", (e) ->
  showNextImage()
  e.preventDefault()

# Start Recording
$(".startRecording").live "click", (e) -> 
  updateTimer(0);  
  #SW.setState("record")
  #showNextImage()
  SC.record
    start: () ->
      SW.setState("record")
      showNextImage()
  
    progress: (ms, avgPeak) ->
      window.recordingPosition = ms;
      updateTimer(ms);
  e.preventDefault()


$("#goToStep3").live "click", (e) ->
  SC.recordStop();
  updateTimer(0);
  SW.setState("finalize")
  e.preventDefault()
  
$("#uploadButton").live "click", (e) ->
  SC.options.site = "soundcloud.com" # TODO remove
  e.preventDefault()
  SC.connect
    connected: ->
      title = $("#title").val()
      title = "A story" if title == ""
      options =
        track: 
          title: title
          sharing: "public"
      SW.setState("upload")
      $("#progressMessage").text("Uploading...")
      SC.recordUpload options, (track) -> 
        $("#progressMessage").text("Processing...")

        storyUrl = "http://storywheel.com/" + track.user.permalink + "/" + track.permalink
        # update description with link to carousel
        # create comments
        i = 0
        $.each slides, ->
          slide = this
          i++
          body = "<a href=" + storyUrl + "#" + slide.imageUrl + ">StoryWheel Picture #" + i + "</a>"
          SC.post track.uri + "/comments", {
            comment: {
              body: body + slide.debug,
              timestamp: slide.timestamp
            }
          }, (comment) ->
            # ignore
        
        SC.put SETTINGS.soundcloudGroup + "/contributions/" + track.id, (contribution) ->
          #contributed
        
        checkState = -> 
          SC.get track.uri, (track) -> 
            if track.state == "finished"
              window.location = track.permalink_url.replace("soundcloud.com", window.location.host)
            else
              window.setTimeout(checkState, 2000)
        window.setTimeout(checkState, 2000)

updateTimer = (ms) ->
  $("#timer").text(SC.Helper.millisecondsToHMS(ms));
    
    
####################################################
################# NEW STUFF ########################

$(".connectInstagram").live 'click', (e) ->
  e.preventDefault()
  instagramUrl = "/connect-instagram"
  window.instagramPopup = SC.Helper.openCenteredPopup(instagramUrl, 1024, 370)


window.instagramToken = null
window.instagramPopup = null
window.instagramCallback = () ->
  popupLocation = window.instagramPopup.location.toString()
  uri = new SC.URI(popupLocation, {decodeQuery: true, decodeFragment: true})
  error = uri.query.error || uri.fragment.error
  window.instagramPopup.close()

  if error
    throw new Error(uri.query.error)
  else
    window.instagramToken = uri.fragment.access_token
    $(".connectInstagram").hide()
    $.ajax(
      dataType: "JSONP"
      url: "https://api.instagram.com/v1/users/self/media/recent?callback=?&count=24&access_token=" + window.instagramToken
      success: (r) ->
        $.each r.data, -> 
          image = 
            url: this.images.standard_resolution.url,
            thumbnail_url: this.images.thumbnail.url,
            timestamp: null
          $("#imageTmpl").tmpl(image).appendTo("ul.all-images");
        $("ul.selection").sortable();
    )

    
    
    
    
    
    
    
    
    
    
    
    
    
    

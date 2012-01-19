# Story Creation

# Load Instagram Pictures

slides = []
window.recordingPosition = 0

    
  

$ ->
  SC.initialize(SETTINGS.soundcloud)
  
  
  uri = new SC.URI(window.location.toString(), {decodeFragment: true});
  accessToken = uri.fragment.access_token;
   

$(".build-your-own").live "click", (e) ->
  SW.setState("connect")
  e.preventDefault()


# List UI
$("ul.all-images li").live "click", (e) ->
  empties = $("ul.selection li.empty")
  if empties.length < 2
    empties.first().clone().appendTo("ul.selection")
  empties.first().replaceWith($(this))


# Second step

showNextImage = ->
  $img = $("#selection li.image").first()
  images = $("#selection li.image")
  imagesLeft = images.length

  console.log(imagesLeft)
  if imagesLeft == 0
    console.log('fin')
    SC.recordStop();
    updateTimer(0);
    SW.setState("finalize")
  else
    $img = images.first()

    SW.showImage($img.attr("data-image-url"))
    slides.push
      imageUrl: $img.attr("data-image-url")
      timestamp: Recorder.flashInterface().recordingDuration()

    $img.remove()
    imagesLeft--
    if imagesLeft == 0
      $("#status").html("This is the last picture.<br/>Finish your story!")
    else
      $("#status").text(imagesLeft + " pictures left.")

$(".goToStep2").live "click", (e) ->
  if $("ul.selection li.image").length > -1
    $("ul.selection li.image").appendTo("ul.step2-selection");
  else
    alert("Pick some photos first")
  SW.setState("prerecord")
  e.preventDefault()


$(window).keyup (e) ->
  if e.keyCode == 32 && $("body#record").length > 0
    showNextImage()
    e.preventDefault()


$("body#record #currentImage").live "click", (e) ->
  console.log('1')
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
  e.preventDefault()
  
$("#uploadButton").live "click", (e) ->
  SC.options.site = "soundcloud.com" # TODO remove
  e.preventDefault()
  SC.connect
    connected: ->
      title = $("#title").val()
      title = "A story" if title == ""
      tags = []
      tags.push("storywheel:image=" + slides[0].imageUrl) # TODO use 150_150
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
        $.each slides, ->
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

$(".emotion .button").live "click", (e) ->
  $(this).toggleClass("red").siblings().removeClass("red")
  e.preventDefault()

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
    SW.setState("pick")
    #$(".connectInstagram").hide()
    $.ajax(
      dataType: "JSONP"
      url: "https://api.instagram.com/v1/users/self/media/recent?callback=?&count=48&access_token=" + window.instagramToken
      success: (r) ->
        $.each r.data, -> 
          image = 
            url: this.images.standard_resolution.url,
            thumbnail_url: this.images.thumbnail.url,
            timestamp: null
          $("#imageTmpl").tmpl(image).appendTo("ul.all-images");
        $("ul.selection").sortable();
    )

    
    
    
    
    
    
    
    
    
    
    
    
    
    

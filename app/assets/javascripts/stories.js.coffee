# Story Creation

# Load Instagram Pictures

slides = []
window.recordingPosition = 0

SETTINGS = 
  soundcloud:
    client_id: "3a57e26203bc5210285a02f8eee95d91"
    redirect_uri: "http://localhost:3000/callback.html"
  instagram:
    client_id: "3a57e26203bc5210285a02f8eee95d91"
    redirect_uri: "http://localhost:3000/callback.html"
  soundcloudGroup: "/groups/59904"
    


$ ->
  SC.initialize(SETTINGS.soundcloud)
  
  
  uri = new SC.URI(window.location.toString(), {decodeFragment: true});
  accessToken = uri.fragment.access_token;
  
  if accessToken
    showScreen("intro");
    $(".intro, .screen").addClass("small")
    $.ajax(
      dataType: "JSONP"
      url: "https://api.instagram.com/v1/users/self/media/recent?callback=?&count=32&access_token=" + accessToken
      success: (r) ->
        $.each r.data, -> 
          image = 
            url: this.images.standard_resolution.url,
            thumbnail_url: this.images.thumbnail.url,
            timestamp: null
          $("#imageTmpl").tmpl(image).appendTo("ul.all-images");
        
        $("ul.selection").sortable();

    )

# List UI

$("ul.all-images li").live "click", (e) ->
  $("ul.selection li.empty").first().replaceWith($(this))

# Reset Button

showScreen = (name) ->
  $(".screen").removeClass("intro").removeClass("rec").removeClass("image").removeClass("small").addClass(name)
  $(".screen ." + name).show().siblings().hide();
  $(".intro").removeClass("small")
  

# Second step

$(".goToStep2").live "click", (e) ->
  if $("ul.selection li.image").length > -1
    $("#step2").show().siblings().hide()
    $("body").removeClass("example-focus").addClass("example-half-focus")
    $("ul.selection li.image").appendTo("ul.step2-selection");
    showScreen("rec");
  else
    alert("Pick some photos first")
  e.preventDefault()

$(".goToStep3").live "click", (e) ->
    $("#step3").show().siblings().hide()
    e.preventDefault()
  #$(".intro").html("<h2>Press record to start. Hit &lt;space&gt; to show the next picture.</h2>")
  
# Recording UI



$("#recordButton.reset}").live "click", (e) -> 
  updateTimer(0);
  SC.record
    start: () ->
      $(".button.nextImage").show()
      $(".goToStep3").hide()
      showScreen("slideshow")
      $(".screen .slideshow .cover").html("");
      setRecorderUIState("recording")
      $("#timer").show()
      nextImage()

    progress: (ms, avgPeak) ->
      window.recordingPosition = ms;
      updateTimer(ms);

  e.preventDefault()


$("#recordButton.recording}").live "click", (e) -> 
  stopRecording()
  e.preventDefault()
  
$(".button.nextImage").live "click", (e) ->
  nextImage()
  e.preventDefault()
  
$("#upload").live "click", (e) ->
  e.preventDefault()
  SC.connect
    connected: ->
      title = $("#title").val()
      if title == ""
        title = "A story"
      options =
        track: 
          title: title
          sharing: "private"

      SC.recordUpload options, (track) -> 
        storyUrl = "http://storywheel.com/" + track.user.permalink + "/" + track.permalink
        # update description with link to carousel
        # create comments
        $.each slides, ->
          slide = this;
          
          body = "<a href=" + storyUrl + "#" + slide.imageUrl + ">StoryWheel Photo</a>"
          SC.post track.uri + "/comments", {
            comment: {
              body: body,
              timestamp: slide.timestamp
            }
          }, (comment) ->
            # ignore
            
        # post to group



nextImage = ->
  $nextLi = $("ul.step2-selection li").first()
  if $nextLi.length > 0
    imageUrl = $nextLi.attr("data-image-url")
    showImage(imageUrl)
    slides.push({
      "imageUrl": imageUrl,
      "timestamp": window.recordingPosition;
    })
    console.log(slides)
    $nextLi.remove()
    
  else
    stopRecording()

stopRecording = ->
  SC.recordStop();
  
  $(".button.nextImage").hide()
  updateTimer(0);
  $(".goToStep3").show()
  setRecorderUIState("reset");
  $("#timer").hide();
  
showImage = (imageUrl) ->
  $(".slideshow").css("background-image", "url(" + imageUrl + ")")
  

updateTimer = (ms) ->
  $("#timer").text(SC.Helper.millisecondsToHMS(ms));

setRecorderUIState = (state) ->
  $("#recordButton").attr("class", state);

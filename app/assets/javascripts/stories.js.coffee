# Story Creation

# Load Instagram Pictures

$ ->
  uri = new SC.URI(window.location.toString(), {decodeFragment: true});
  accessToken = uri.fragment.access_token;
  
  if accessToken
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


# Second step

$(".goToStep2").live "click", (e) ->
  if $("ul.selection li.image").length > -1
    $("#step2").show().siblings().hide()
    $("body").removeClass("example-focus").addClass("example-half-focus")
    $("ul.selection li.image").appendTo("ul.step2-selection");
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
  SC.record({
    start: () ->
      $(".button.nextImage").show()
      $(".goToStep3").hide()
      
      
      setRecorderUIState("recording")
      $("#timer").show();
    progress: (ms, avgPeak) ->
      recordingPosition = ms;
      updateTimer(ms);
    
    
  })
  e.preventDefault()


$("#recordButton.recording}").live "click", (e) -> 
  stopRecording()
  e.preventDefault()
  
$(".button.nextImage").live "click", (e) ->
  $nextLi = $("ul.step2-selection li").first()
  console.log $nextLi
  if $nextLi.length > 0
    $("#image}").css("background-image", "url(" + $nextLi.attr("data-image-url") + ")")
    $nextLi.hide()
  else
    stopRecording()

  e.preventDefault()

stopRecording = ->
  SC.recordStop();
  
  $(".button.nextImage").hide()
  updateTimer(0);
  $(".goToStep3").show()
  setRecorderUIState("reset");
  $("#timer").hide();
  
  
nextImage = ->
  

updateTimer = (ms) ->
  $("#timer").text(SC.Helper.millisecondsToHMS(ms));

setRecorderUIState = (state) ->
  $("#recordButton").attr("class", state);

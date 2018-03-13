$( document ).on('turbolinks:load', function() {
  $('#spotify-connection-dropdown').on('click', function(e) {
    $('#spotify-connection-dropdown').toggleClass('is-active');
  });

  $('body').click(function(e) {
    $('#spotify-connection-dropdown').removeClass('is-active');
  });

  $('#spotify-connection-dropdown').click(function(e){
	   e.stopPropagation();
  });

  $('#playlist-select2').select2({
    placeholder: 'Select a playlist'
  });

  $('#playlist-select2').on("select2:select", function(e) {
    window.location.href = "/playlists/" + e.params.data.id;
  });
})

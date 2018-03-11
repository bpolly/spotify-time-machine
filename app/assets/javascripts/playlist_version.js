$( document ).on('turbolinks:load', function() {
  $('#spotify-connection-dropdown').on('click', function(e) {
    $('#spotify-connection-dropdown').addClass('is-loading');
  });

  $('body').click(function(e) {
    $('#spotify-connection-dropdown').removeClass('is-active');
  });

  $('#spotify-connection-dropdown').click(function(e){
	   e.stopPropagation();
  });

  $('#save-playlist-btn').on('click', function(e) {
    e.preventDefault();
    $('#save-playlist-btn').blur();
    $('#save-playlist-btn').addClass('is-loading');
    // $('#save-playlist-btn').prop('disabled', true);
  });
})

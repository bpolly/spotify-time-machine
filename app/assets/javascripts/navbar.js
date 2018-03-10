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
})

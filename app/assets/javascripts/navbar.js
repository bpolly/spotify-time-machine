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

  function formatState (state) {
    if (!state.id) {
      return state.text;
    }
    var baseUrl = "/user/pages/images/flags";
    var $state = $(
      '<span><img src="' + baseUrl + '/' + state.element.value.toLowerCase() + '.png" class="img-flag" /> ' + state.text + '</span>'
    );
    return $state;
  };

  $('#playlist-select2').select2({
    placeholder: 'Select a playlist',
    templateSelection: formatState
  });

  $('#playlist-select2').on("select2:select", function(e) {
    window.location.href = "/playlists/" + e.params.data.id;
  });
})

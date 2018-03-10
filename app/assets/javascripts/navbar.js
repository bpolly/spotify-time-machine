$( document ).on('turbolinks:load', function() {
  $('#spotify-connection-dropdown').on('click', function(e) {
    $('#spotify-connection-dropdown').toggleClass('is-active');
    e.preventDefault();
  });

  $(document).on("click", function(event){
        var $trigger = $('#spotify-connection-dropdown');
        if($trigger !== event.target && !$trigger.has(event.target).length){
            $('#spotify-connection-dropdown').removeClass('is-active');
        }
    });
})

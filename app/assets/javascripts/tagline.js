$(document).ready(function() {

  function size_tagline() {
    var window_width = $(window).outerWidth() - 10;
    var height = 105.6;

    if (window_width >= 940) {
      var inner_width = window_width * 0.2;
      height = (inner_width - 10) * 0.6;    
    }
     
    $('.tagline').height(height);

  };

  size_tagline();

  $(window).resize(size_tagline);

});

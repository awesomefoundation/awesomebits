$(document).ready(function() {

  function size_tagline() {
    var window_width = $(window).outerWidth() - 10;

    if (window_width >= 940) {
      var inner_width = window_width * 0.2;
    }
    else {
      window_width = 940 - 10;
      var inner_width = window_width * 0.2;
    }

    var height = (inner_width - 10) * 0.6;
    $('.tagline').height(height);

  };

  size_tagline();

  $(window).resize(size_tagline);

});

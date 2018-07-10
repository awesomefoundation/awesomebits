// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require magnific-popup
//= require owl.carousel
//= require_tree .

$(document).ready(function() {
  var owl = $('.owl-carousel');

  owl.owlCarousel({
    loop: false,
    nav: true,
    responsive: {
    0: {
      items: 2
    },
    600: {
      items: 2
    },
    960: {
      items: 2
    },
    1200: {
      items: 2
    }
  }});

/*  owl.on('mousewheel', '.owl-stage', function(e) {
    if (e.deltaY > 0) {
      owl.trigger('next.owl');
    } else {
  owl.trigger('prev.owl');
    }
  e.preventDefault();
  });*/

  $(".next_button").click(function() {
      // owl.trigger('owl.next');
      owl.trigger('next.owl');
  });

  $(".prev_button").click(function() {
     // owl.trigger('owl.prev');
      owl.trigger('prev.owl');
  });


})


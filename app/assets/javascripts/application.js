// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

$('a.chapters').toggle(function() {
  $('.chapter-menu').addClass("expanded");
  $('a.chapters').addClass("active");
}, function() {
  $('.chapter-menu').removeClass("expanded");
  $('a.chapters').removeClass("active");
});

$('a.chapter-selection').toggle(function() {
  $('.chapter-selector').addClass("expanded");
  $('a.chapter-selection').addClass("expanded");
}, function() {
  $('.chapter-selector').removeClass("expanded");
  $('a.chapter-selection').removeClass("expanded");
});

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

window.onload=function(){
    $(".chapter-header-wrapper").thumbnailScroller({
        scrollerType: "hoverAccelerate",
        scrollerOrientation: "horizontal",
        scrollSpeed: 2,
        scrollEasing: "easeOutCirc",
        scrollEasingAmount: 600,
        acceleration: 25,
        scrollSpeed: 200,
        noScrollCenterSpace: 200,
        autoScrolling: 0,
        autoScrollingSpeed: 2000,
        autoScrollingEasing: "easeInOutQuad",
        autoScrollingDelay: 500
    });
}

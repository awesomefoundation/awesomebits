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

$(document).ready( function() {
  function size_message() {
    var project_height = $('.project:first-child').outerHeight();
    $('.tagline').height(project_height - 10);
  }

  $('.project:first-child img').load(size_message);

  $(window).resize(size_message);
});

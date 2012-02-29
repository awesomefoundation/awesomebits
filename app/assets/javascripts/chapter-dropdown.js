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

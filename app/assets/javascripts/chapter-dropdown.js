$('a.chapters').on('click', function(event) {
  event.preventDefault();
  $('.chapter-menu').toggleClass('expanded');
  $('a.chapters').toggleClass('active');
});

$('a.chapter-selection').on('click', function(event) {
  event.preventDefault();
  $('.chapter-selector').toggleClass('expanded');
  $('a.chapter-selection').toggleClass('expanded');
});
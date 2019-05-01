$('a.chapters').on('click', function(event) {
  event.preventDefault();
  $('.chapter-menu').toggleClass('expanded');
  $('a.chapters').toggleClass('active');
});

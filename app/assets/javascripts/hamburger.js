jQuery(function($) {
  $('.hamburger').click(function() {
    $(this).parent().toggleClass('shownav');
  });
});

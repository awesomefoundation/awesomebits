/* Score filter dropdowns — each .score-filter-wrapper is independent */

$('a.score-selection').on('click', function(event) {
  event.preventDefault();
  var $wrapper = $(this).closest('.score-filter-wrapper');
  var $selector = $wrapper.find('.score-selector');
  var isOpen = $selector.hasClass('expanded');

  // Close all dropdowns first
  $('.score-selector').removeClass('expanded');
  $('a.score-selection').removeClass('expanded');

  if (!isOpen) {
    $selector.addClass('expanded');
    $(this).addClass('expanded');
  }
});

$(document).click(function(e) {
  if (!$(e.target).closest('.score-filter-wrapper').length) {
    $('.score-selector').removeClass('expanded');
    $('a.score-selection').removeClass('expanded');
  }
});

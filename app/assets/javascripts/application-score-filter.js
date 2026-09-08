/* Score filter dropdowns — each .score-filter-wrapper is independent */

$('a.score-selection').on('click', function(event) {
  event.preventDefault();
  const $wrapper = $(this).closest('.score-filter-wrapper');
  const $selector = $wrapper.find('.score-selector');
  const isOpen = $selector.hasClass('expanded');

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

/* Show/hide score badges — client-side toggle with localStorage persistence */
(function() {
  var STORAGE_KEY = 'awesomebits-show-scores';
  var $checkbox = $('#show-scores');

  // Restore saved state on page load
  if (localStorage.getItem(STORAGE_KEY) === 'true') {
    $checkbox.prop('checked', true);
    $('.signal-score').show();
  }

  $checkbox.on('change', function() {
    var checked = $(this).is(':checked');
    localStorage.setItem(STORAGE_KEY, checked);
    if (checked) {
      $('.signal-score').show();
    } else {
      $('.signal-score').hide();
    }
  });
})();

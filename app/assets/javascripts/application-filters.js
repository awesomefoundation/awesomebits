/* Hides and shows chapter selection drop down on admin pages */

var applicationFilterChapterMenuVisible = false;

/* Show/hide dropdown menu when chapter selection filter */
$('a.chapter-selection').on('click', function(event) {
  event.preventDefault();
  if (!applicationFilterChapterMenuVisible) {
    applicationFilterChapterMenuVisible = true;
    $('.chapter-selector').addClass('expanded');
    $('a.chapter-selection').addClass('expanded');
    
    /* Vertically bound chapter selection dropdown menu on admin panel for non-mobile/touch devices */
    if (!('ontouchstart' in window)) {
      $('.chapter-selector').addClass('bounded');
    }
    
  }
  else {
    applicationFilterChapterMenuVisible = false;
    $('.chapter-selector').removeClass('expanded');
    $('a.chapter-selection').removeClass('expanded');
  }
});


/* Hide dropdown menu on any click that is not the chapter selection filter */
$(document).click(function(e) {
  if(!$(e.target).closest('a.chapter-selection').length) {
    if(applicationFilterChapterMenuVisible) {
      applicationFilterChapterMenuVisible = false;
      $('.chapter-selector').removeClass('expanded');
      $('a.chapter-selection').removeClass('expanded');
    }
  }
});

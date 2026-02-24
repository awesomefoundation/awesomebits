/* Hides and shows score filter drop down on admin pages */
/* Mirrors the chapter-selection dropdown pattern */

var scoreFilterMenuVisible = false;

$('a.score-selection').on('click', function(event) {
  event.preventDefault();
  if (!scoreFilterMenuVisible) {
    scoreFilterMenuVisible = true;
    $('.score-selector').addClass('expanded');
    $('a.score-selection').addClass('expanded');
  } else {
    scoreFilterMenuVisible = false;
    $('.score-selector').removeClass('expanded');
    $('a.score-selection').removeClass('expanded');
  }
});

$(document).click(function(e) {
  if (!$(e.target).closest('a.score-selection').length) {
    if (scoreFilterMenuVisible) {
      scoreFilterMenuVisible = false;
      $('.score-selector').removeClass('expanded');
      $('a.score-selection').removeClass('expanded');
    }
  }
});

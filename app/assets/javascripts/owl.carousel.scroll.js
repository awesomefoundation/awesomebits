/* Prevents vertical scrolling of Owl carousel when on mobile/touch devices */

var carousel = document.getElementById('owl-carousel');

if (carousel != null) {
  carousel.addEventListener('touchmove', function(e) {
    e.preventDefault();
  }, false);
}
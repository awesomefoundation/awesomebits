/*
 * Ensures that the project gallery
 * navigation arrows are always displayed
 * when on touch enabled device 
*/

var gallery = document.getElementById('project-gallery');

if (gallery != null && 'ontouchstart' in window) {
  $(gallery).addClass("touch-device");
}
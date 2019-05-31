/* Launches project gallery lightbox from button on project show pages */

$("#launch-gallery").on("click", function(event) {
  event.preventDefault();
  document.getElementById('project-gallery').querySelector('.image').click();
});
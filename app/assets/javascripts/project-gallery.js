/* Launches project gallery lightbox from button on project show pages */

$("#launch-gallery").on("click", function(event) {
  event.preventDefault();
  $("#project-gallery .image:first-child > img").trigger("click");
});
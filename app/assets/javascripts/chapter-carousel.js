$(window).ready(function(){
//    $(".chapter-header-wrapper").thumbnailScroller({
//        scrollerType: "clickButtons",
//        scrollerOrientation: "horizontal",
//        scrollSpeed: 2,
//        scrollEasing: "easeOutCirc",
//        scrollEasingAmount: 600,
//        acceleration: 25,
//        scrollSpeed: 200,
//        noScrollCenterSpace: 200,
//        autoScrolling: 0,
//        autoScrollingSpeed: 2000,
//        autoScrollingEasing: "easeInOutQuad",
//        autoScrollingDelay: 500
//    });
     var owl = $('.chapter-projects');
     owl.owlCarousel({
       loop: false,
       nav: true,
       margin:10,
       autoWidth:true,
       dotsContainer: '.owl-dots-wrapper #owl-dots',
       responsive: {
        0: {
          items: 2
        },
        600: {
          items: 2
        },
        960: {
          items: 2
        },
        1200: {
          items: 3
        }
      }});

       $(".next_button").click(function() {
         owl.trigger('next.owl');
       });

       $(".prev_button").click(function() {
         owl.trigger('prev.owl');
       });
});

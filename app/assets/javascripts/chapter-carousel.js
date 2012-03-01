$(window).ready(function(){
    $(".chapter-header-wrapper").thumbnailScroller({
        scrollerType: "clickButtons",
        scrollerOrientation: "horizontal",
        scrollSpeed: 2,
        scrollEasing: "easeOutCirc",
        scrollEasingAmount: 600,
        acceleration: 25,
        scrollSpeed: 200,
        noScrollCenterSpace: 200,
        autoScrolling: 0,
        autoScrollingSpeed: 2000,
        autoScrollingEasing: "easeInOutQuad",
        autoScrollingDelay: 500
    });
});

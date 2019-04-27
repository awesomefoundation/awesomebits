$ ->
  $owl = $(".chapter-projects")

  slidesCount = $owl.children().length

  $owl.owlCarousel
    loop:               false,
    nav:                true,
    navContainerClass:  "owl-nav-round",
    navText:            ["", ""]
    navClass:           ["owl-nav-left", "owl-nav-right"],
    margin:             10,
    dotsContainer:      ".owl-dots-wrapper #owl-dots",
    autoWidth:          false,
    callbacks:          true,
    responsiveClass:    true,
    responsive:
      0:     {items: 1, slideBy: 1, dotsEach: Math.ceil(slidesCount / 10) },
      800:   {items: 2, slideBy: 2, dotsEach: Math.ceil(slidesCount / 20) },
      1200:  {items: 3, slideBy: 3, dotsEach: Math.ceil(slidesCount / 30) },

  # add custom left/right nav button triggers
  $(".owl-wrapper .left").click (e)->
    e.preventDefault()
    $owl.trigger("prev.owl")

  $(".owl-wrapper .right").click (e)->
    e.preventDefault()
    $owl.trigger("next.owl")

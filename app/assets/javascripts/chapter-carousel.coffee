$ ->
  $owl = $(".chapter-projects")

  # dotsEach on the smallest size reduces the number of dots on the screen tenfold,
  # which should ensure that the dots don't flow to a second line
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
      0:     {items: 1, dotsEach: 10},
      800:   {items: 2},
      1200:  {items: 3},

  # add custom left/right nav button triggers
  $(".owl-wrapper .left").click (e)->
    e.preventDefault()
    $owl.trigger("prev.owl")

  $(".owl-wrapper .right").click (e)->
    e.preventDefault()
    $owl.trigger("next.owl")

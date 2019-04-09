$ ->
  $owl = $(".chapter-projects")

  # there may be many slides, and we don't want nav dots to span several lines
  # OwlCarousel has a `dotsEach` setting which fits just right, but it can not be used with `autoWidth` mode
  # so we add a CSS rule which hides all the dots, except for each Nth dot, so that the total number of dots
  # is kept no more than M
  slidesCount = $owl.children().length
  maxDots     = 40 # picked by hand to fit the smallest screen widths
  dotsEach    = Math.ceil(slidesCount / maxDots) # show only each `dotsEach` dot

  style = document.createElement('style')
  style.innerHTML = ".owl-dot { display: none !important; }\n.owl-dot:nth-child(#{dotsEach}n+1) { display: inline-block !important; }";
  document.body.appendChild(style)

  # setup OwlCarousel (this has to be below adjusting dots since the carousel alters the DOM tree of $owl)
  $owl.owlCarousel
    loop:               false,
    nav:                true,
    navContainerClass:  "owl-nav-round",
    navText:            ["", ""]
    navClass:           ["owl-nav-left", "owl-nav-right"],
    margin:             10,
    autoWidth:          false,
    dotsContainer:      ".owl-dots-wrapper #owl-dots",
    callbacks:          true,
    responsiveClass:    true,
    responsive:
      0:     {items: 1},
      800:   {items: 2},
      1200:  {items: 3},

  # add custom left/right nav button triggers
  $(".owl-wrapper .left").click (e)->
    e.preventDefault()
    $owl.trigger("prev.owl")

  $(".owl-wrapper .right").click (e)->
    e.preventDefault()
    $owl.trigger("next.owl")

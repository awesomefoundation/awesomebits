function Slideshow(selector, options) {
  return {
    run: function() {
      (function($){
        var options = options || {};
        var fadeSpeed = options.speed || 400;
        var fadeDelay = options.delay || 5000;
        var clock = options.clock;
        var clicked_since_last_autoupdate = false;

        showAll = function() {
          var all = $(selector);
          all.last().fadeIn(fadeSpeed, function(){
            all.show();
            all.removeClass('faded');
          });
        }

        hideAll = function() {
          var all = $(selector);
          var middles = $(selector + ":not(:first-of-type):not(:last-of-type)");
          var top = all.last();
          middles.hide();
          middles.addClass("faded");
          top.fadeOut(fadeSpeed);
          top.addClass("faded");
        }

        fadeToNext = function() {
          var visible = $(selector + ':not(.faded)');
          if (visible.length <= 1) {
            showAll();
          } else {
            visible.last().fadeOut(fadeSpeed);
            visible.last().addClass('faded');
          }
        }

        fadeToPrev = function() {
          var hidden = $(selector + '.faded');
          if (hidden.length == 0) {
            hideAll();
          } else {
            hidden.first().fadeIn(fadeSpeed);
            hidden.first().removeClass('faded');
          }
        }

        clickLeft = function() {
          clicked_since_last_autoupdate = true;
          fadeToPrev();
        }

        clickRight = function() {
          clicked_since_last_autoupdate = true;
          fadeToNext();
        }

        clockTick = function() {
          if(clicked_since_last_autoupdate) {
            clicked_since_last_autoupdate = false;
            return;
          }
          fadeToNext();
        }

        $(window).bind("tick", clockTick);
        $(".arrows .right").click(clickRight);
        $(".arrows .left").click(clickLeft);
      })(jQuery)
    }
}}

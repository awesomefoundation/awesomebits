jQuery(function($) {
	$('.hamburger').click(function() {
		$(this).siblings('ol').toggle();
	});
});

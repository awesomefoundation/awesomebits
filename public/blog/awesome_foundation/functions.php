<?php

/* UTILITY FUNCTIONS / CONFIG
 ******************************************************************************/

add_theme_support('post-thumbnails');

function excerpt_length($length) {
	return 40;
}
function excerpt_more($output) {
	return ' &mdash; <span><a href="'.get_permalink().'">continue reading</a></span>';
}
add_filter('excerpt_length', 'excerpt_length');
add_filter('excerpt_more', 'excerpt_more');

if ( function_exists('register_sidebar') )
    register_sidebar();

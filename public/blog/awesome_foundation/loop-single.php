<?php
  while (have_posts()) : the_post();

    echo '<div class="post" id="', the_ID(), '">';
    echo '<header>';
    echo '<h2><a href="'.get_permalink().'">', the_title(), '</a></h2>';
    echo '<p class="date">'; the_date(); echo '</p>';
    echo '</header>';
    the_content();
    echo '</div>';

    echo '<section class="comments">';
    comments_template();
    echo '</section>';

  endwhile;
?>

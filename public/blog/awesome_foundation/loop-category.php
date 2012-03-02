<section class="posts">
  <?php
    if (get_search_query())
      echo '<p>results for ', get_search_query(), '</p>';

    while (have_posts()) : the_post();

      echo '<div class="post" id="', the_ID(), '">';
        echo '<header>';
          echo '<h2><a href="'.get_permalink().'">', the_title(), '</a></h2>';
          echo '<p class="date">'; the_date(); echo '</p>';
        echo '</header>';
        if ( has_post_thumbnail() ) {
          echo '<div class="post-hero">';
            echo get_the_post_thumbnail(get_the_ID(), 'thumbnail');
          echo '</div>';
        };
        the_excerpt();
      echo '</div>';

    endwhile;
  ?>
</section>

<!doctype html>
<html>
<?php get_header('head'); ?>
<body>
  <?php get_header('nav'); ?>
  <section class="container-wrapper">
    <section class="bread-crumbs">
      <div class="bread-crumb-wrapper">
        <?php
          if(function_exists ('bcn_display')) {
            bcn_display();
          }
        ?>
      </div>
    </section>
    <section class="container">
      <section class="single-post">
        <?php
          // get the first category listed for this article
          // will have to be changed to always get dominant category rather than features etc.
          $category = get_the_category();
          $category = $category[0]->slug;
          // if category specific single loop exists, use it, otherwise use default single loop
          if (locate_template("loop-$category.php"))
            get_template_part('loop', $category);
          else {
            get_template_part('loop', 'single');
          }
        ?>
      </section>
      <?php get_sidebar(); ?>
    </section>
  </section>
  <?php get_footer(); ?>
</body>
</html>

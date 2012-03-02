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
      <?php get_template_part('loop', 'category'); ?>
      <?php get_sidebar(); ?>
    </section>
  </section>
  <?php get_footer(); ?>
</body>
</html>

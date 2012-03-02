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
  <script type="text/javascript" src="http://use.typekit.com/uck6mip.js"></script>
  <script type="text/javascript">try{Typekit.load();}catch(e){}</script>
</body>
</html>

<?php get_header(); ?>

<h1>Welcome to Sample Theme</h1>
<p>This is a minimal WordPress theme template.</p>

<?php
if ( have_posts() ) :
    while ( have_posts() ) : the_post();
        the_title('<h2>', '</h2>');
        the_content();
    endwhile;
else :
    echo '<p>No content found</p>';
endif;
?>

<?php get_footer(); ?>


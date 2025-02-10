<?php get_header(); ?>

<main>
    <h1>Welcome to My Custom Theme</h1>
    <?php if ( have_posts() ) : while ( have_posts() ) : the_post(); ?>
        <article>
            <h2><?php the_title(); ?></h2>
            <p><?php the_content(); ?></p>
        </article>
    <?php endwhile; endif; ?>
</main>

<?php get_footer(); ?>

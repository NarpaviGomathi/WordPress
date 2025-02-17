<?php get_header(); ?>
<div class="content">
    <h1><?php bloginfo('name'); ?></h1>
    <p><?php bloginfo('description'); ?></p>
    
    <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
        <article>
            <h2><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2>
            <p><?php the_excerpt(); ?></p>
        </article>
    <?php endwhile; endif; ?>
</div>
<?php get_footer(); ?>

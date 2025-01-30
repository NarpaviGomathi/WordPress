<?php
function my_intro_theme_setup() {
    add_theme_support('title-tag'); // Adds dynamic title support
}
add_action('after_setup_theme', 'my_intro_theme_setup');
?>

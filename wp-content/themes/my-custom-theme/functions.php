<?php
// Theme setup
function mycustomtheme_setup() {
    add_theme_support( 'title-tag' );
    add_theme_support( 'post-thumbnails' );
    register_nav_menus( array(
        'primary' => __( 'Primary Menu', 'mycustomtheme' ),
    ) );
}
add_action( 'after_setup_theme', 'mycustomtheme_setup' );

// Enqueue styles and scripts
function mycustomtheme_scripts() {
    wp_enqueue_style( 'mycustomtheme-style', get_stylesheet_uri() );
}
add_action( 'wp_enqueue_scripts', 'mycustomtheme_scripts' );
?>

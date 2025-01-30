<?php
// Enqueue theme styles and scripts
function my_custom_theme_assets() {
    wp_enqueue_style( 'my-custom-style', get_stylesheet_uri() );
}
add_action( 'wp_enqueue_scripts', 'my_custom_theme_assets' );

// Register menu locations
function my_custom_theme_menus() {
    register_nav_menus(
        array(
            'main_menu' => __( 'Main Menu' ),
        )
    );
}
add_action( 'after_setup_theme', 'my_custom_theme_menus' );

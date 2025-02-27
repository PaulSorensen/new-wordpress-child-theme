#!/bin/bash
################################################################################
#  Script Name : New WordPress Child Theme
#  Author      : Paul Sørensen
#  Website     : https://paulsorensen.io
#  GitHub      : https://github.com/paulsorensen
#  Version     : 1.1
#  Last Update : 27.02.2025
#
#  Description:
#  Creates a child theme based on an existing WordPress theme.
#
#  Usage:
#  sudo ./new-wordpress-child-theme.sh -t <parent_theme_directory>
#
#  Example:
#  sudo ./new-wordpress-child-theme.sh -t /var/www/domain.com/wwwroot/wp-content/themes/ParentTheme
#
#  If you found this script useful, a small tip is appreciated ❤️
#  https://buymeacoffee.com/paulsorensen
################################################################################

# Exit immediately if a command exits with a non-zero status
set -e

BLUE='\033[38;5;81m'
NC='\033[0m'
echo -e "${BLUE}New Wordpress Child Theme by paulsorensen.io${NC}\n"

# Parse command-line arguments
while getopts "t:" opt; do
    case "$opt" in
        t) THEME_DIR="$OPTARG" ;;
        *) echo "Usage: sudo $0 -t <parent_theme_directory>"; exit 1 ;;
    esac
done

# Ensure the theme directory is provided
if [ -z "$THEME_DIR" ]; then
    echo "Error: Theme directory not specified."
    echo "Use -t <parent_theme_directory>."
    echo "Example: sudo ./new-wordpress-child-theme.sh -t /var/www/paulsorensen.io/wwwroot/wp-content/themes/neve"
    exit 1
fi

# Ensure the theme directory exists
if [ ! -d "$THEME_DIR" ]; then
    echo "Error: Specified theme directory does not exist: $THEME_DIR"
    exit 1
fi

# Extract the theme name from the provided path
THEME_NAME=$(basename "$THEME_DIR")
CHILD_THEME_DIR="$(dirname "$THEME_DIR")/${THEME_NAME}-child"

# Check if the child theme already exists
if [ -d "$CHILD_THEME_DIR" ]; then
    echo "Error: Child theme '${THEME_NAME}-child' already exists."
    exit 1
fi

# Prompt user for author information
read -p "Enter Theme URI (Click 'ENTER' to leave empty): " THEME_URL
read -p "Enter Author Name (Click 'ENTER' to leave empty): " THEME_AUTHOR
read -p "Enter Author URI (Click 'ENTER' to leave empty): " THEME_AUTHOR_URI

# Create the child theme directory
mkdir -p "$CHILD_THEME_DIR"

echo "Creating child theme at: $CHILD_THEME_DIR"

# Create style.css file for the child theme
cat <<EOL > "$CHILD_THEME_DIR/style.css"
/*
Theme Name: ${THEME_NAME}-child
Theme URI: ${THEME_URL}
Author: ${THEME_AUTHOR}
Author URI: ${THEME_AUTHOR_URI}
Description: Child theme for ${THEME_NAME}
Template: ${THEME_NAME}
Version: 1.0
License: GNU General Public License v3 or later
License URI: https://www.gnu.org/licenses/gpl-3.0.txt
Text Domain: ${THEME_NAME}-child
*/
EOL

# Create functions.php file for the child theme
cat <<EOL > "$CHILD_THEME_DIR/functions.php"
<?php
/**
 * Enqueue parent theme styles
 */
function ${THEME_NAME}_child_enqueue_styles() {
    wp_enqueue_style( '${THEME_NAME}-parent-style', get_template_directory_uri() . '/style.css' );
}
add_action( 'wp_enqueue_scripts', '${THEME_NAME}_child_enqueue_styles' );
EOL

# Copy screenshot.png if it exists in the parent theme
for EXT in png jpg jpeg; do
    if [ -f "$THEME_DIR/screenshot.$EXT" ]; then
        cp "$THEME_DIR/screenshot.$EXT" "$CHILD_THEME_DIR/"
        break
    fi
done

echo "Setting ownership and permissions..."
chown -R www-data:www-data "$CHILD_THEME_DIR"
find "$CHILD_THEME_DIR" -type d -exec chmod 750 {} \;
find "$CHILD_THEME_DIR" -type f -exec chmod 640 {} \;

echo "Child theme '${THEME_NAME}-child' successfully created!"
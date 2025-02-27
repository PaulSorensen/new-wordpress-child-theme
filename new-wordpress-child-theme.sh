#!/bin/bash
################################################################################
#  Script Name : New WordPress Child Theme
#  Author      : Paul Sørensen
#  Website     : https://paulsorensen.io
#  GitHub      : https://github.com/paulsorensen
#  Version     : 1.4
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
echo -e "${BLUE}New WordPress Child Theme by paulsorensen.io${NC}\n"

# Parse command-line arguments
while getopts "t:" opt; do
    case "$opt" in
        t) PARENT_THEME_DIR="$OPTARG" ;;
        *) echo "Usage: sudo $0 -t <parent_theme_directory>"; exit 1 ;;
    esac
done

# Ensure the parent theme directory is provided
if [ -z "$PARENT_THEME_DIR" ]; then
    echo "Error: Parent theme directory not specified."
    echo "Use -t <parent_theme_directory>."
    echo "Example: sudo ./new-wordpress-child-theme.sh -t /var/www/domain.com/wwwroot/wp-content/themes/ParentTheme"
    exit 1
fi

# Ensure the parent theme directory exists
if [ ! -d "$PARENT_THEME_DIR" ]; then
    echo "Error: Specified parent theme directory does not exist: $PARENT_THEME_DIR"
    exit 1
fi

# Extract the parent theme name from the provided path
THEME_NAME=$(basename "$PARENT_THEME_DIR")

# Prompt user for the child theme name
read -p "Please enter a name for your child theme (it is recommended to end with '-child'. Eg. Theme-child): " CHILD_THEME_NAME

# Function to transform input into folder-friendly name (lowercase, only dashes allowed, spaces removed)
format_folder_name() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//'
}

# Define child theme folder name and path using the transformation
CHILD_THEME_FOLDER_NAME=$(format_folder_name "$CHILD_THEME_NAME")
CHILD_THEME_PATH="$(dirname "$PARENT_THEME_DIR")/${CHILD_THEME_FOLDER_NAME}"

# Check if the user-defined child theme already exists
if [ -d "$CHILD_THEME_PATH" ]; then
    echo "Error: Child theme folder '${CHILD_THEME_FOLDER_NAME}' already exists."
    exit 1
fi

# Prompt user for additional details
read -p "Enter Theme URI (Click 'ENTER' to leave empty): " THEME_URL
read -p "Enter Author Name (Click 'ENTER' to leave empty): " THEME_AUTHOR
read -p "Enter Author URI (Click 'ENTER' to leave empty): " THEME_AUTHOR_URI

# Create the child theme directory
mkdir -p "$CHILD_THEME_PATH"

echo "Creating child theme at: $CHILD_THEME_PATH"

# Properly format Theme Name for style.css
format_theme_name() {
    echo "$1" | sed -E '
        s/[-_]+/ /g;                      # Replace dashes and underscores with a single space
        s/([a-z])([A-Z0-9])/\1 \2/g;      # Add space between lowercase and uppercase/number (if needed)
        s/ +/ /g;                         # Collapse multiple spaces into one
        s/(^|[[:space:]])([a-z])/\1\U\2/g # Capitalize first letter of each word
    ' | sed 's/^ *//;s/ *$//'             # Trim leading/trailing spaces
}

# Apply proper formatting for `Theme Name` and `Description`
CHILD_THEME_NAME_FORMATTED=$(format_theme_name "$CHILD_THEME_NAME")
THEME_NAME_FORMATTED=$(format_theme_name "$THEME_NAME")

# Create style.css file for the child theme
cat <<EOL > "$CHILD_THEME_PATH/style.css"
/*
Theme Name: ${CHILD_THEME_NAME_FORMATTED}
Theme URI: ${THEME_URL}
Author: ${THEME_AUTHOR}
Author URI: ${THEME_AUTHOR_URI}
Description: Child theme for ${THEME_NAME_FORMATTED}
Template: ${THEME_NAME}
Version: 1.0
License: GNU General Public License v3 or later
License URI: https://www.gnu.org/licenses/gpl-3.0.txt
Text Domain: ${CHILD_THEME_FOLDER_NAME}
*/
EOL

# Create functions.php file for the child theme
cat <<EOL > "$CHILD_THEME_PATH/functions.php"
<?php
function ${CHILD_THEME_FOLDER_NAME//-/_}_enqueue_styles() {
    wp_enqueue_style('${THEME_NAME}-parent-style', get_template_directory_uri() . '/style.css');
    wp_enqueue_style('${CHILD_THEME_FOLDER_NAME}-style', get_stylesheet_directory_uri() . '/style.css', array('${THEME_NAME}-parent-style'), wp_get_theme()->get('Version'));
}
add_action('wp_enqueue_scripts', '${CHILD_THEME_FOLDER_NAME//-/_}_enqueue_styles');
?>
EOL

# Copy screenshot.png if it exists in the parent theme
for EXT in png jpg jpeg; do
    if [ -f "$PARENT_THEME_DIR/screenshot.$EXT" ]; then
        cp "$PARENT_THEME_DIR/screenshot.$EXT" "$CHILD_THEME_PATH/"
        break
    fi
done

echo "Setting ownership and permissions..."
chown -R www-data:www-data "$CHILD_THEME_PATH"
find "$CHILD_THEME_PATH" -type d -exec chmod 750 {} \;
find "$CHILD_THEME_PATH" -type f -exec chmod 640 {} \;

echo -e "${BLUE}Child theme '${CHILD_THEME_NAME}' successfully created with folder name '${CHILD_THEME_FOLDER_NAME}'!${NC}"
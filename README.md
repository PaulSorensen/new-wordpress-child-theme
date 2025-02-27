# New WordPress Child Theme

## Overview
**New WordPress Child Theme** is a Bash script that automates the creation of a child theme based on an existing WordPress theme. It simplifies the process by setting up the required files and permissions automatically.

## Features
- Creates a child theme from an existing WordPress theme.
- Generates `style.css` and `functions.php` for the child theme.
- Copies `screenshot.png` from the parent theme if available.
- Sets proper ownership (`www-data:www-data`) and secure permissions.

## Requirements
Before running the script, ensure that:
- You have `sudo` privileges.
- The parent theme exists in the WordPress themes directory.

## Usage
Run the script with the parent theme directory as an argument:
```bash
sudo ./new-wordpress-child-theme.sh -t <parent_theme_directory>
```
Example:
```bash
sudo ./new-wordpress-child-theme.sh -t /var/www/domain.com/wwwroot/wp-content/themes/ParentTheme
```

## Configuration
- You will be prompted to enter author information which will be saved in style.css of the child theme.

## Enjoying This Script?
**If you found this script useful, a small tip is appreciated ❤️**  
[https://buymeacoffee.com/paulsorensen](https://buymeacoffee.com/paulsorensen)

## License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License.

**Legal Notice:** If you edit and redistribute this code, you must mention the original author, **Paul Sørensen** ([paulsorensen.io](https://paulsorensen.io)), in the redistributed code or documentation.

**Copyright (C) 2025 Paul Sørensen ([paulsorensen.io](https://paulsorensen.io))**

See the LICENSE file in this repository for the full text of the GNU General Public License v3.0, or visit [https://www.gnu.org/licenses/gpl-3.0.txt](https://www.gnu.org/licenses/gpl-3.0.txt).
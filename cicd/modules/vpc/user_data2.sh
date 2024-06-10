#!/bin/bash

# Update package index
sudo apt update

# Install PHP and required extensions
sudo apt install -y php php-cli php-mysql

# Check PHP version
php --version

# Create a PHP test file
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# Set permissions for the test file
sudo chown www-data:www-data /var/www/html/info.php

# Restart Apache to apply changes
sudo systemctl restart apache2
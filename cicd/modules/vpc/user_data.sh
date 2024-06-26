#!/bin/bash
sudo apt update
sudo apt install -y  apache2
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo "<html><body><h1>Instance AZ: $AZ,<p>DB address: ${db_address}</p><p>DB port: ${db_port}</p></h1></body></html>" | sudo tee /var/www/html/index.html
sudo systemctl restart apache2

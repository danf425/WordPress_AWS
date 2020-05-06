#!/bin/bash
# Modify you db password. Change "your_root_password"
DBPASSWORD_ADMIN=test
MYSQL_USER=test
MYSQL_PW=test
DBNAME=test-db
# Security Keys. Change Them!
AUTH_KEY=some-unique-value1
SECURE_AUTH_KEY=some-unique-value2
LOGGED_IN_KEY=some-unique-value3
NONCE_KEY=some-unique-value4 
AUTH_SALT=some-unique-value5
SECURE_AUTH_SALT=some-unique-value6
LOGGED_IN_SALT=some-unique-value7
NONCE_SALT=some-unique-value8

#LAMP Instructions: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-lamp-amazon-linux-2.html#securing-maria-db
#WordPress Instructions:  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/hosting-wordpress.html

sudo yum update -y

# Download Wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# Install LAMP
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server

# Enable HTTPD
sudo systemctl start httpd
sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
rm /var/www/html/phpinfo.php

# Start and configure MariaDB
sudo systemctl start mariadb
sudo yum install expect -y
# Run mysql_secure_installation
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set the root password?\"
send \"y\r\"
expect \"New password:\"
send \"${DBPASSWORD_ADMIN}\r\"
expect \"Re-enter new password:\"
send \"${DBPASSWORD_ADMIN}\r\"   
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
sudo yum -y purge expect
sudo systemctl enable mariadb

# Install phpMyAdmin
sudo yum install php-mbstring -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz

# Configure MySql
mysql -u root -p${DBPASSWORD_ADMIN} -e "CREATE USER \"${MYSQL_USER}\"@\"localhost\" IDENTIFIED BY \"${MYSQL_PW}\"; CREATE DATABASE \`${DBNAME}\`; GRANT ALL PRIVILEGES ON \`${DBNAME}\`.* TO \"${MYSQL_USER}\"@\"localhost\"; FLUSH PRIVILEGES;"
# Configure Wordpress
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/database_name_here/${DBNAME}/g" wordpress/wp-config.php
sed -i "s/username_here/${MYSQL_USER}/g" wordpress/wp-config.php
sed -i "s/password_here/${MYSQL_PW}/g" wordpress/wp-config.php
sed -i "s/AUTH_KEY',         'put your unique phrase here/AUTH_KEY',         '${AUTH_KEY}/g" wordpress/wp-config.php
sed -i "s/SECURE_AUTH_KEY',  'put your unique phrase here/SECURE_AUTH_KEY',  '${SECURE_AUTH_KEY}/g" wordpress/wp-config.php
sed -i "s/LOGGED_IN_KEY',    'put your unique phrase here/LOGGED_IN_KEY',    '${LOGGED_IN_KEY}/g" wordpress/wp-config.php
sed -i "s/NONCE_KEY',        'put your unique phrase here/NONCE_KEY',        '${NONCE_KEY}/g" wordpress/wp-config.php
sed -i "s/AUTH_SALT',        'put your unique phrase here/AUTH_SALT',        '${AUTH_SALT}/g" wordpress/wp-config.php
sed -i "s/SECURE_AUTH_SALT', 'put your unique phrase here/SECURE_AUTH_SALT', '${SECURE_AUTH_SALT}/g" wordpress/wp-config.php
sed -i "s/LOGGED_IN_SALT',   'put your unique phrase here/LOGGED_IN_SALT',   '${LOGGED_IN_SALT}/g" wordpress/wp-config.php
sed -i "s/NONCE_SALT',       'put your unique phrase here/NONCE_SALT',       '${NONCE_SALT}/g" wordpress/wp-config.php
# Make your website accessible from root 
cp -r wordpress/* /var/www/html/


sudo yum install php72-gd


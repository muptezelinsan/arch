#! /bin/bash

pacman -Syyu
pacman -S --needed --noconfirm apache
sed -i 's/LoadModule unique_id_module/#LoadModule unique_id_module/g' /etc/httpd/conf/httpd.conf
systemctl enable httpd
systemctl restart httpd
systemctl status httpd

cat << EOF > /srv/http/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta http-equiv="X-UA-Compatible" content="ie=edge" />
  <title>Welcome</title>
 </head>
<body>
  <h2>Welcome to my Web Server test page</h2>
</body>
</html>
EOF

pacman -S --needed --noconfirm mysql

mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

systemctl enable mysqld
systemctl start mysqld
systemctl status mysqld

mysql_secure_installation

pacman -S --needed --noconfirm php php-apache

sed -i 's/LoadModule mpm_event_module/#LoadModule mpm_event_module/g' /etc/httpd/conf/httpd.conf

sed -i 's/#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/g' /etc/httpd/conf/httpd.conf

cat << EOF >> /etc/httpd/conf/httpd.conf
LoadModule php_module modules/libphp.so
AddHandler php-script php
Include conf/extra/php_module.conf
EOF


cat << EOF > /srv/http/test.php
<?php
phpinfo();
EOF

systemctl restart httpd

pacman -S --needed --noconfirm phpmyadmin

sed -i 's/;extension=bz2/extension=bz2/g' /etc/php/php.ini
sed -i 's/;extension=mysqli/extension=mysqli/g' /etc/php/php.ini

cat << EOF > /etc/httpd/conf/extra/phpmyadmin.conf
Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"
<Directory "/usr/share/webapps/phpMyAdmin">
DirectoryIndex index.php
AllowOverride All
Options FollowSymlinks
Require all granted
</Directory>
EOF

cat << EOF >> /etc/httpd/conf/httpd.conf
Include conf/extra/phpmyadmin.conf
EOF

echo "phpmayadmin şifresi için yönlendiriliyorsunuz"
sleep 5s
nano /etc/webapps/phpmyadmin/config.inc.php

systemctl restart httpd

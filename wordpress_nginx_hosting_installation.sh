#!/bin/bash
Domain_Name="testwp.paradiseio.com"
Web_Dir="/usr/share/nginx/wordpress"

################ Cai dat repo remi va epel cho lenh Yum #############

yum update -y && yum install epel-release -y
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

##################### Cai dat repo nginx va repo mariadb ############

cat > /etc/yum.repos.d/nginx.repo << EOF
[nginx] 
name=nginx repo 
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/ 
gpgcheck=0 
enabled=1
EOF

cat >  /etc/yum.repos.d/mariadb.repo << EOF
[mariadb] 
name = MariaDB 
baseurl = http://yum.mariadb.org/10.1/centos7-amd64 
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB 
gpgcheck=1
EOF

################### Kich hoat Remi cho php56 ########################

sed -i '30s/enabled=0/enable=1/' /etc/yum.repos.d/remi.repo

########### Cai dat nginx, mariadb, php, php-fpm tu repo Remi #######

yum --enablerepo=remi install nginx MariaDB-client MariaDB-server php php-common php-fpm -y

##############cai dat php modules tu repo Remi#####################

yum --enablerepo=remi install php-mysql php-pgsql php-pecl-mongo php-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml php-pecl-apc php-cli php-pear php-pdo -y

###################### Cau hinh nginx cho Vhost #####################
#xoa file default Vhost

if [ -f /etc/nginx/conf.d/default.conf ];
then
	echo "Xoa file default vhost"
	rm -rf /etc/nginx/conf.d/default.conf
fi

cat > /etc/nginx/conf.d/$Domain_Name.conf << EOF
server {
        listen       80;
        server_name  testwp.paradiseio.com;
        root         /usr/share/nginx/wordpress;
        index   index.php index.html;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
                index index.php;
        }
        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }

	 location ~ \.php$ {
            include /etc/nginx/fastcgi_params;
            fastcgi_pass  127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }

        # Disable favicon.ico logging
        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }
        # Allow robots and disable logging
        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }
        # Enable permalink structures
        if (!-e \$request_filename) {
                rewrite . /index.php last;
        }
	# Disable static content logging and set cache time to max
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
        # Deny access to htaccess and htpasswd files
        location ~ /\.ht {
                deny  all;
        }
}
EOF

################## Cau hinh php-fpm ########################

sed -i '23s/apache/nginx/' /etc/php-fpm.d/www.conf
sed -i '25s/apache/nginx/' /etc/php-fpm.d/www.comf
sed -i '49,50s/nobody/nginx/' /etc/php-fpm.d/www.conf
sed -i '49,51s/^;//' /etc/php-fpm.d/www.conf

######## download wordpress, change the parameter ##########

yum install wget unzip -y
wget http://wordpress.org/latest.zip -P ~/
unzip ~/latest.zip -d /usr/share/nginx/
cat $Web_Dir/wp-config-sample.php > $Web_Dir/wp-config.php
sed -i 's/database_name_here/wpdatabase/' $Web_Dir/wp-config.php
sed -i 's/username_here/wpuser/' $Web_Dir/wp-config.php
sed -i 's/password_here/123456/' $Web_Dir/wp-config.php



################# Cau hinh MariaDB ########################

service mariadb start
service mariadb enable

mysql_secure_installation <<EOF

Y
123456
123456
y
y
y
y
EOF

mysql -uroot -p123456 <<EOF
CREATE USER wpuser@localhost IDENTIFIED BY "123456";
CREATE DATABASE wpdatabase;
GRANT ALL ON wpdatabase.* TO wpuser@localhost;
FLUSH PRIVILEGES;
EOF


############## Enable & Re-start all service #########
systemctl enable nginx
systemctl enable php-fpm

service mariadb restart
service nginx restart
service php-fpm restart

############## End of Script #########################

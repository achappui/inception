#!/bin/bash
set -e

#environement
# DOMAIN_NAME=$DOMAIN_NAME
# WEBSITE_TITLE=$WEBSITE_TITLE
# WORDPRESS_DB_HOST=$WORDPRESS_DB_HOST

#secrets
MARIADB_WORDPRESS_NAME=$(cat /run/secrets/mariadb_wordpress_name)
MARIADB_WORDPRESS_USER=$(cat /run/secrets/mariadb_wordpress_user)
MARIADB_WORDPRESS_PASSWORD=$(cat /run/secrets/mariadb_wordpress_password)

WORDPRESS_ADMIN_USER=$(cat /run/secrets/wordpress_admin_user)
WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WORDPRESS_ADMIN_MAIL=$(cat /run/secrets/wordpress_admin_mail)

WORDPRESS_USER=$(cat /run/secrets/wordpress_user)
WORDPRESS_PASSWORD=$(cat /run/secrets/wordpress_password)
WORDPRESS_MAIL=$(cat /run/secrets/wordpress_mail)

if [ ! -f /var/www/html/wp-config.php ]; then
    cd /var/www/html
    wp config create \
        --dbname=$MARIADB_WORDPRESS_NAME \
        --dbuser=$MARIADB_WORDPRESS_USER \
        --dbpass=$MARIADB_WORDPRESS_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \

    wp core install \
        --url=$DOMAIN_NAME \
        --title=$WEBSITE_TITLE \
        --admin_user=$WORDPRESS_ADMIN_USER \
        --admin_password=$WORDPRESS_ADMIN_PASSWORD \
        --admin_email=$WORDPRESS_ADMIN_MAIL \

    wp user create $WORDPRESS_USER $WORDPRESS_MAIL --role=author --user_pass=$WORDPRESS_PASSWORD
fi

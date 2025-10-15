FROM debian:12.12

RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysqli \
    php8.2-curl \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-gd \
    php8.2-zip \
    php8.2-opcache \
    php8.2-cli \
    curl \
    ca-certificates

WORKDIR /var/www/html

RUN curl -O https://wordpress.org/wordpress-6.8.3.tar.gz \
    && tar -xzf wordpress-6.8.3.tar.gz -C . --strip-components=1 \
    && rm wordpress-6.8.3.tar.gz \
    && chown -R www-data:www-data /var/www/html \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && chown -R www-data:www-data /var/log

RUN apt-get purge -y curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin

COPY init/docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh

WORKDIR /docker-entrypoint-initwp.d

COPY init/init-wp.sh init-wp.sh

WORKDIR /etc/php/8.2/fpm/pool.d

COPY conf/php-fpm.conf www.conf

VOLUME /var/www/html

USER www-data

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
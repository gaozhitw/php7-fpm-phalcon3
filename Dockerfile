FROM php:7.2-fpm AS builder

RUN \
    apt-get update && \
    apt-get install -y git libwebp-dev libjpeg-dev libpng-dev libfreetype6-dev libgmp-dev libicu-dev

RUN \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include && \
    docker-php-ext-install pdo_mysql mbstring sockets gd opcache exif gmp bcmath intl

RUN \
    pecl install redis && \
    pecl install xdebug-3.1.6

RUN \
    cd ${HOME} && \
    git clone https://github.com/phalcon/cphalcon.git && \
    cd cphalcon && \
    git checkout v3.4.5 && \
    cd build/php7/64bits && \
    phpize && \
    export CFLAGS="-O2 -g" && \
    ./configure && \
    make && make install

FROM caddy:2.6 AS caddy
FROM composer:2 AS composer

FROM php:7.2-fpm AS final

# intl extension dependent on libicu-dev
# gmp extension dependent on libgmp-dev

RUN \
    apt-get update && \
    apt-get install -y libwebp-dev libjpeg-dev libpng-dev libfreetype6-dev libgmp-dev libicu-dev && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/list/*

COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20170718/ /usr/local/lib/php/extensions/no-debug-non-zts-20170718/

RUN docker-php-ext-enable pdo_mysql mbstring sockets gd opcache exif gmp bcmath intl redis phalcon

RUN \
    mkdir -p ${HOME}/php-default-conf && \
    cp -R /usr/local/etc/* ${HOME}/php-default-conf

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY --from=composer /usr/bin/composer /usr/bin/composer

ADD ["./docker-entrypointer.sh", "/root/"]

CMD ["sh", "-c", "${HOME}/docker-entrypointer.sh"]
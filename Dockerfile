FROM php:7.2-fpm

RUN \
    apt-get update && \
    apt-get install -y git libwebp-dev libjpeg62-turbo-dev libpng-dev libfreetype6-dev libmcrypt-dev libssl-dev libgmp-dev libicu-dev procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/list/*

RUN \
    cd ${HOME} && \
    git clone https://github.com/phalcon/cphalcon.git && \
    cd cphalcon/build/php7/64bits && \
    phpize && \
    export CFLAGS="-O2 -g" && \
    ./configure && \
    make && make install && \
    docker-php-ext-enable phalcon && \
    rm -rf ${HOME}/cphalcon
    
RUN \
    pecl install redis && \
    pecl install xdebug && \
    docker-php-ext-enable redis xdebug && \
    pecl clear-cache

RUN \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure mbstring && \
    docker-php-ext-configure sockets && \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure gmp && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-configure intl && \
    docker-php-ext-install pdo_mysql mbstring sockets gd opcache exif gmp bcmath intl

RUN \
    mkdir -p ${HOME}/php-default-conf && \
    cp -R /usr/local/etc/* ${HOME}/php-default-conf

ADD ["./docker-entrypointer.sh", "/root/"]

ENTRYPOINT ["sh", "-c", "${HOME}/docker-entrypointer.sh"]
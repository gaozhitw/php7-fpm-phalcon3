FROM php:7-fpm

RUN \
    apt-get update && \
    apt-get install -y git libvpx-dev libjpeg62-turbo-dev libpng12-dev libfreetype6-dev libmcrypt-dev libssl-dev libmcrypt-dev && \
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
    docker-php-ext-enable redis && \
    pecl clear-cache

RUN \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure mbstring && \
    docker-php-ext-configure sockets && \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-vpx-dir=/usr/include --with-freetype-dir=/usr/include && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure mcrypt && \
    docker-php-ext-install pdo_mysql mbstring sockets gd opcache exif mcrypt

RUN \
    mkdir -p ${HOME}/php-default-conf && \
    cp -R /usr/local/etc/* ${HOME}/php-default-conf

ADD ["./docker-entrypointer.sh", "/root/"]

ENTRYPOINT ["sh", "-c", "${HOME}/docker-entrypointer.sh"]
FROM php:8.1.1-fpm-alpine

COPY opcache.ini $PHP_INI_DIR/conf.d/
COPY cerealis-api.ini $PHP_INI_DIR/conf.d/

RUN apk add --update $PHPIZE_DEPS \
    make \
    # for git
    git \
    # For intl
    icu-dev gettext-dev icu-libs \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-install -j$(nproc) \
        intl \
        opcache \
        pdo_mysql


RUN mkdir -p /.composer/cache \
    && chmod -R 777 /.composer/cache

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    # Make sure we're installing what we think we're installing!
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=2.2.4 \
    && rm -f /tmp/composer-setup.*

RUN curl -sLO https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar \
    && chmod +x cachetool.phar \
    && mv cachetool.phar /usr/local/bin/.

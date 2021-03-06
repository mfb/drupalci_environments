FROM       php:5.4.39-apache
MAINTAINER drupalci


ENV DRUPALCI TRUE

RUN buildDeps=" \
    g++ \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libpq-dev \
    libssl-dev \
    libtidy-dev \
    libxslt1-dev \
    ncurses-dev \
    unzip \
    " \
    && set -x \
    && apt-get update && apt-get install -y curl git libc6 libcomerr2 libfreetype6 libgcc1 \
    libmcrypt4 libgcrypt20 libgpg-error0 libicu52 libjpeg62-turbo libkeyutils1 liblzma5 \
    libpng12-0 libpq5 libreadline6 libtidy-0.99-0 libtinfo5 libxslt1.1 mysql-client \
    postgresql-client sqlite3 sudo zlib1g --no-install-recommends \
    && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install bcmath exif ftp gettext intl mcrypt mbstring mysql mysqli \
    pcntl pdo_mysql pdo_pgsql pgsql shmop soap sockets sysvsem sysvshm tidy wddx xmlrpc xsl zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && echo | pecl install apc \
    && echo | pecl install xdebug \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps

RUN curl -o /usr/local/bin/composer http://getcomposer.org/composer.phar \
    && chmod 775 /usr/local/bin/composer \
    && curl -o /usr/local/bin/drush http://files.drush.org/drush.phar \
    && chmod +x /usr/local/bin/drush \
    && /usr/local/bin/drush --version

COPY ./conf/apache2/vhost.conf /etc/apache2/sites-available/drupal.conf
COPY ./conf/php/php.ini /usr/local/etc/php/php.ini
COPY ./conf/php/php-cli.ini /usr/local/etc/php/php-cli.ini
COPY ./conf/start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

##
# Apache Configuration.
##
RUN a2dismod mpm_event \
    && a2enmod mpm_prefork \
    && a2enmod rewrite \
    && a2dissite 000-default.conf \
    && a2ensite drupal

CMD ["/usr/local/bin/start.sh"]

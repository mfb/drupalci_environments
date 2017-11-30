#######
# Base
#####
FROM debian:jessie

ENV DRUPALCI TRUE

######
# Apache Setup
######
RUN apt-get update && apt-get install -y apache2-bin apache2.2-common apache2-dbg --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN set -ex \
	\
	&& sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' /etc/apache2/envvars \
	\
	&& . /etc/apache2/envvars \
	&& for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
		/var/www/html \
	; do \
		rm -rvf "$dir" \
		&& mkdir -p "$dir" \
		&& chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
	done

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
		echo '<FilesMatch \.php$>'; \
		echo '\tSetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'DirectoryIndex disabled'; \
		echo 'DirectoryIndex index.php index.html'; \
		echo; \
		echo '<Directory /var/www/>'; \
		echo '\tOptions -Indexes'; \
		echo '\tAllowOverride All'; \
		echo '</Directory>'; \
	} | tee /etc/apache2/conf-available/docker-php.conf \
	&& a2enconf docker-php

COPY ./conf/apache2/vhost.conf /etc/apache2/sites-available/drupal.conf

RUN a2enmod rewrite \
    && a2dissite 000-default.conf \
    && a2ensite drupal

#######
# Php Setup
######
RUN apt-get update && apt-get install -y --no-install-recommends \
        autoconf \
		ca-certificates \
		curl \
		file \
		g++ \
		gcc \
		gdb \
		libc-dev \
		libedit2 \
		libsqlite3-0 \
		libxml2 \
		make \
		pkg-config \
		re2c \
		xz-utils \
		&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/etc/php/conf.d

ENV PHP_CFLAGS="-O2 -g"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS=""

ENV GPG_KEYS A917B1ECDA84AEC2B568FED6F50ABC807BD5DCD0 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E

# PHP Version
ENV PHP_VERSION 7.1.12
ENV PHP_URL="https://secure.php.net/get/php-7.1.12.tar.xz/from/this/mirror" PHP_ASC_URL="https://secure.php.net/get/php-7.1.12.tar.xz.asc/from/this/mirror"
ENV PHP_SHA256="a0118850774571b1f2d4e30b4fe7a4b958ca66f07d07d65ebdc789c54ba6eeb3"

RUN set -xe; \
	\
	fetchDeps=' \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	wget -O php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_ASC_URL" ]; then \
		wget -O php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		rm -r "$GNUPGHOME"; \
	fi; \
	\
	apt-get purge -y --auto-remove $fetchDeps

COPY docker-php-source /usr/local/bin/

RUN set -xe \
	&& buildDeps=" \
        apache2-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libwebp-dev \
        libpq-dev \
        libsqlite3-dev \
        libssl-dev \
        libtidy-dev \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        ncurses-dev \
    " \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& docker-php-source extract \
	&& cd /usr/src/php \
	&& export CFLAGS="-O2 -g" \
		CPPFLAGS="-O2 -g" \
		LDFLAGS="" \
	&& ./configure \
    		--with-config-file-path=/usr/local/etc/php \
    		--with-config-file-scan-dir=/usr/local/etc/php/conf.d \
    		--enable-ftp \
    		--enable-mbstring \
    		--enable-mysqlnd \
    		--with-curl \
    		--with-libedit \
    		--with-openssl \
    		--with-zlib \
    		--with-kerberos \
            --with-openssl \
            --with-mysql=mysqlnd \
            --with-mysqli=mysqlnd \
            --with-pdo-mysql=mysqlnd \
            --with-pdo-sqlite \
            --with-pdo-pgsql \
            --with-readline \
            --with-png-dir \
            --with-freetype-dir \
            --with-zlib-dir \
            --with-jpeg-dir \
            --with-mcrypt \
            --with-xsl \
            --with-tidy \
            --with-xmlrpc \
            --with-gettext=shared \
    		--with-gd \
            --with-webp-dir \
            --with-pear \
            --enable-sockets \
            --enable-exif \
            --enable-zip \
            --enable-soap \
            --enable-sysvsem \
            --enable-cgi \
            --enable-sysvshm \
            --enable-shmop \
            --enable-pcntl \
            --enable-bcmath \
            --enable-xmlreader \
            --enable-intl \
            --enable-wddx \
            --enable-opcache \
    		--with-apxs2 \
    	&& make -j "$(nproc)" \
    	&& make install \
    	&& make clean


COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

# install pecl extensions for apcu, xdebug, and yaml
RUN docker-php-ext-pecl-install APCu xdebug yaml-2.0.0 \
    && sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-pecl-xdebug.ini \
    && apt-get update \
    && apt-get install -y mysql-client postgresql-client sudo git sqlite3 --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/php/php.ini /usr/local/etc/php/php.ini
COPY ./conf/php/php-cli.ini /usr/local/etc/php/php-cli.ini

# Install Composer, Drush
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --filename composer --install-dir /usr/local/bin \
  && curl -o /usr/local/bin/drush http://files.drush.org/drush.phar \
  && chmod +x /usr/local/bin/drush \
  && /usr/local/bin/drush --version

# Install phantomjs, supervisor
RUN curl -SL "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2" -o /phantomjs-2.1.1-linux-x86_64.tar.bz2 \
  && tar -jxf /phantomjs-2.1.1-linux-x86_64.tar.bz2 -C / \
  && mv /phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin/phantomjs \
  && rm -f /phantomjs-2.1.1-linux-x86_64.tar.bz2 \
  && rm -rf /phantomjs-2.1.1-linux-x86_64 \
  && chmod 755 /usr/bin/phantomjs \
  && apt-get update \
  && apt-get install -y supervisor fontconfig \
  && rm -rf /var/lib/apt/lists/*

COPY ./conf/supervisor-phantomjs.conf /etc/supervisor/conf.d/phantomjs.conf

ENTRYPOINT ["docker-php-entrypoint"]

COPY apache2-foreground /usr/local/bin/
WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]

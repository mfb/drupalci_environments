######
# Base
######
FROM ubuntu:trusty

ENV DRUPALCI TRUE

#######
# Apache Setup
######
RUN apt-get update && apt-get install -y apache2-bin apache2-dbg --no-install-recommends && rm -rf /var/lib/apt/lists/*

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

RUN mkdir -p /usr/local/etc/php/conf.d

RUN apt-get update && apt-get install -y \
		php5 \
        php5-cgi \
        php5-cli \
        php5-common \
        php5-curl \
        php5-gd \
        php5-json \
        php5-ldap \
        php5-mysql \
        php5-odbc \
        php5-pgsql \
        php5-sqlite \
        php5-tidy \
        php5-xmlrpc \
        php5-xsl \
        php5-apcu \
		ca-certificates \
		curl \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

COPY ./conf/php/php.ini /etc/php/cgi/php.ini
COPY ./conf/php/php-cli.ini /etc/php/cli/php.ini

# Install Composer, Drush
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
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
COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

COPY apache2-foreground /usr/local/bin/
WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]


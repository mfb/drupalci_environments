FROM       drupalci/web-base
MAINTAINER drupalci

##
# PHP 5.4.31
##
RUN echo "--enable-intl" >> /opt/phpenv/plugins/php-build/share/php-build/default_configure_options && \
    echo "--enable-wddx" >> /opt/phpenv/plugins/php-build/share/php-build/default_configure_options && \
    /opt/phpenv/plugins/php-build/install.sh && \
    sudo php-build -i development --pear 5.4.39 /opt/phpenv/versions/5.4.39 && \
    sudo chown -R root:root /opt/phpenv && \
    phpenv rehash && \
    phpenv global 5.4.39 && \
    ln -s /opt/phpenv/shims/php /usr/bin/php && \
    rm -rf /tmp/pear /tmp/php-build*

RUN echo | pecl install apc

##
# Upgrade curl to version 7.38
##
RUN apt-get update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:n-muench/programs-ppa2 && \
    apt-get update && \
    apt-get install -y curl && \
    apt-get clean && apt-get -y autoremove

##
# copying php.ini for compiled php
##
COPY ./conf/cli-php.ini /etc/php5/cli/php.ini
COPY ./conf/opt-php.ini /opt/phpenv/versions/5.4.39/etc/php.ini
COPY ./conf/opt-apc.ini /opt/phpenv/versions/5.4.39/etc/conf.d/apc.ini
COPY ./conf/opt-gettext.ini /opt/phpenv/versions/5.4.39/etc/conf.d/gettext.ini
COPY ./conf/opt-xdebug.ini /opt/phpenv/versions/5.4.39/etc/conf.d/xdebug.ini

CMD ["/usr/local/bin/start.sh"]

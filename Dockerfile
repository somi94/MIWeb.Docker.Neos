FROM php:7.2-apache

# ARG FLOW_USER
# ENV FLOW_USER=$FLOW_USER
# ENV FLOW_USER noink

ARG BASE_PACKAGE="neos/neos-base-distribution"
ARG BASE_VERSION="4.0.*"

ARG FLOW_USER="root"
ENV FLOW_USER "$FLOW_USER"
#ARG SSL_DOMAIN
#ENV SSL_DOMAIN "$SSL_DOMAIN"
#ARG SSL_EMAIL
#ENV SSL_EMAIL "$SSL_EMAIL"

# install dependencies
RUN apt-get -y update
#RUN if [ -n "${SSL_DOMAIN}" ]; then apt-get install -y certbot python-certbot-apache; fi
RUN apt-get install -y git
RUN apt-get install -y sudo
RUN apt-get install -y zip zlib1g-dev unzip #zlib1g-dev zlib-dev

# apache
ADD vhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
RUN if [ "${FLOW_USER}" != "root" ]; then adduser "${FLOW_USER}"; fi
RUN if [ "${FLOW_USER}" != "root" ]; then usermod -a -G www-data "${FLOW_USER}"; fi
RUN usermod -a -G www-data root

# php
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip

#install Imagemagick & PHP Imagick ext
RUN apt-get update && apt-get install -y \
        libmagickwand-dev --no-install-recommends

RUN pecl install imagick && docker-php-ext-enable imagick

# composer
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod a+x /usr/local/bin/composer

# flow
ARG FLOW_RUN_MODE
ENV FLOW_RUN_MODE "$FLOW_RUN_MODE"
# WORKDIR /var/www/html
# RUN composer install
# RUN ./flow core:setfilepermissions root www-data www-data

# ADD ../../app-data /var/www/data
# WORKDIR /var/www/html
# RUN chown /var/www/html/run
ADD container-start /var/docker/container-start

#neos
RUN composer create-project $BASE_PACKAGE:$BASE_VERSION /var/www/html
RUN ./flow core:setfilepermissions $FLOW_USER www-data www-data

CMD ["/var/docker/container-start"]
# CMD runuser -l ${FLOW_USER} -c "/var/www/html/run.sh ${FLOW_USER} ${FLOW_RUN_MODE}"

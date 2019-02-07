FROM php:7.2-apache

ARG BASE_PACKAGE="neos/neos-base-distribution"
ARG BASE_VERSION="4.0.*"

ARG FLOW_USER="root"
ENV FLOW_USER "$FLOW_USER"

# install dependencies
RUN apt-get -y update
RUN apt-get install -y git
RUN apt-get install -y sudo
RUN apt-get install -y zip zlib1g-dev unzip #zlib1g-dev zlib-dev

# apache
ADD vhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite
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

VOLUME /var/www/html

#neos
#RUN composer create-project $BASE_PACKAGE:$BASE_VERSION /var/www/html
#RUN mkdir -p Data/Temporary
#RUN mkdir -p Data/Persistent
#RUN ./flow core:setfilepermissions $FLOW_USER www-data www-data

#start script
ADD container-commands /usr/share/neos-utils
ADD container.sh /usr/local/bin/neos-utils
RUN chmod a+x /usr/local/bin/neos-utils /usr/share/neos-utils/*

CMD ["neos-utils","start"]

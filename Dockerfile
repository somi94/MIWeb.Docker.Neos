FROM php:7.2-apache

#ARG BASE_PACKAGE="neos/neos-base-distribution"
#ARG BASE_VERSION="4.0.*"

#ARG FLOW_USER="root"
#ENV FLOW_USER "$FLOW_USER"

# install dependencies
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends git zip zlib1g-dev unzip && \
	apt-get install -y gettext-base && \
	apt-get install -y sudo

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


#neos
#RUN composer create-project $BASE_PACKAGE:$BASE_VERSION /var/www/html
#RUN mkdir -p Data/Temporary
#RUN mkdir -p Data/Persistent
#RUN ./flow core:setfilepermissions $FLOW_USER www-data www-data
ADD Settings.yaml /usr/share/neos-utils/Settings.yaml

#start script
ADD container-commands /usr/share/neos-utils
ADD container.sh /usr/local/bin/neos-utils
RUN chmod a+x /usr/local/bin/neos-utils /usr/share/neos-utils/*

ADD app /usr/share/neos-project

#ARG BUILD_REPOSITORY="https://github.com/neos/neos-base-distribution.git"
#ARG BUILD_VERSION=""
#ARG BUILD_PATH_BASE="/usr/share/neos-base"
#ARG BUILD_PATH_RELEASE="/var/www/html"
#ARG BUILD_USER="root"

#RUN neos-utils build-base

CMD ["neos-utils","start"]

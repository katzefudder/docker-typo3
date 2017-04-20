FROM php:7.1-apache
MAINTAINER Florian Dehn

# Install packages
RUN apt-get update && \
apt-get -yq --force-yes install mysql-client git curl imagemagick zip zlib1g-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev && \
rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
ADD typo3.conf /etc/apache2/sites-enabled/000-default.conf

# Adjust some php settings
ADD typo3.php.ini /usr/local/etc/php/conf.d/

RUN rm -fr /app && mkdir /app
VOLUME [ "/app/uploads", "/app/fileadmin"]
RUN rm -fr /var/www/html && ln -s /app /var/www/html

# Add script to create 'typo3' DB
ADD run-typo3.sh /run-typo3.sh
RUN chmod 755 /*.sh

# Expose environment variables
ENV DB_HOST db
ENV DB_PORT 3306
ENV DB_NAME typo3
ENV DB_USER admin
ENV DB_PASS **ChangeMe**
ENV INSTALL_TOOL_PASSWORD password

EXPOSE 80
CMD ["/bin/bash", "-c", "/run-typo3.sh"]

ADD AdditionalConfiguration.php /app/typo3conf/

RUN /usr/local/bin/docker-php-ext-install opcache
RUN /usr/local/bin/docker-php-ext-install mysqli
RUN /usr/local/bin/docker-php-ext-install zip
RUN /usr/local/bin/docker-php-ext-install soap
RUN /usr/local/bin/docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependencies defined in composer.json
ADD composer.json /app/
ADD composer.lock /app/
RUN composer install
FROM ghcr.io/openconext/openconext-basecontainers/php80-apache2:latest
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
SHELL ["/bin/bash", "--login", "-c"]
RUN apt update && apt -y install git unzip
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN nvm install 14
RUN npm install -g yarn
RUN pecl install xdebug-3.2.0 && docker-php-ext-enable xdebug


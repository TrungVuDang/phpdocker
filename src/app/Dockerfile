FROM --platform=linux/amd64 ubuntu:22.04 as stage-amd64
FROM --platform=linux/arm64 arm64v8/ubuntu:jammy as stage-arm64

LABEL maintainer="Trung Vu"

ARG WWWGROUP
ARG NODE_VERSION=18

WORKDIR /home/sail/www

ENV TZ=UTC
ENV DEBIAN_FRONTEND noninteractive

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip nano git supervisor sqlite3 libcap2-bin libpng-dev iputils-ping \
        python2  software-properties-common\
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C \
    && apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && mkdir /run/php \
    && apt-get install -y nginx \
        php7.2-cli php7.2-dev php7.2-fpm \
        php7.2-pgsql php7.2-sqlite3 php7.2-gd \
        php7.2-curl php7.2-memcached \
        php7.2-imap php7.2-mysql php7.2-mbstring \
        php7.2-xml php7.2-zip php7.2-bcmath php7.2-soap \
        php7.2-intl php7.2-readline php7.2-pcov \
        php7.2-msgpack php7.2-igbinary php7.2-ldap \
        php7.2-redis php7.2-xdebug \
        \
        php7.4-cli php7.4-dev php7.4-fpm \
        php7.4-pgsql php7.4-sqlite3 php7.4-gd \
        php7.4-curl php7.4-memcached \
        php7.4-imap php7.4-mysql php7.4-mbstring \
        php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap \
        php7.4-intl php7.4-readline php7.4-pcov \
        php7.4-msgpack php7.4-igbinary php7.4-ldap \
        php7.4-redis php7.4-xdebug \
        \
        php8.0-cli php8.0-dev php8.0-fpm \
        php8.0-pgsql php8.0-sqlite3 php8.0-gd \
        php8.0-curl php8.0-memcached \
        php8.0-imap php8.0-mysql php8.0-mbstring \
        php8.0-xml php8.0-zip php8.0-bcmath php8.0-soap \
        php8.0-intl php8.0-readline php8.0-pcov \
        php8.0-msgpack php8.0-igbinary php8.0-ldap \
        php8.0-redis php8.0-swoole php8.0-xdebug \
        \
        php8.1-cli php8.1-dev php8.1-fpm \
        php8.1-pgsql php8.1-sqlite3 php8.1-gd \
        php8.1-curl \
        php8.1-imap php8.1-mysql php8.1-mbstring \
        php8.1-xml php8.1-zip php8.1-bcmath php8.1-soap \
        php8.1-intl php8.1-readline \
        php8.1-ldap \
        php8.1-msgpack php8.1-igbinary php8.1-redis php8.1-swoole \
        php8.1-memcached php8.1-pcov php8.1-xdebug \
        \
        php8.2-cli php8.2-dev php8.2-fpm \
        php8.2-pgsql php8.2-sqlite3 php8.2-gd \
        php8.2-curl \
        php8.2-imap php8.2-mysql php8.2-mbstring \
        php8.2-xml php8.2-zip php8.2-bcmath php8.2-soap \
        php8.2-intl php8.2-readline \
        php8.2-ldap \
        php8.2-msgpack php8.2-igbinary php8.2-redis php8.2-swoole \
        php8.2-memcached php8.2-pcov php8.2-xdebug

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
#     && . ~/.nvm/nvm.sh \
#     && nvm install node \
#     && nvm alias default node \
#     && nvm use default

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH


RUN apt-get install -y mysql-client \
    && apt-get install -y postgresql-client \
    && npm install --global yarn

RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

RUN rm -rf /etc/nginx/sites-enabled \
    && ln -s /etc/nginx/sites-available /etc/nginx/sites-enabled

RUN sed -i 's/^#force_color_prompt.*$/force_color_prompt=yes/g' /root/.bashrc \
    && cp /root/.bashrc /home/sail/

RUN openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=mydomain.com" \
    -addext "subjectAltName=DNS:mydomain.com" -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
    && cp /etc/ssl/certs/nginx-selfsigned.crt /var/www/html/;

COPY nginx-default /etc/nginx/sites-available/default
COPY start-container /usr/local/bin/start-container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY php72.ini /etc/php/7.2/cli/conf.d/99-sail.ini
COPY php74.ini /etc/php/7.4/cli/conf.d/99-sail.ini
COPY php80.ini /etc/php/8.0/cli/conf.d/99-sail.ini
COPY php81.ini /etc/php/8.1/cli/conf.d/99-sail.ini
COPY php82.ini /etc/php/8.2/cli/conf.d/99-sail.ini

COPY xdebug.ini /etc/php/7.2/cli/conf.d/20-xdebug.ini
COPY xdebug.ini /etc/php/7.4/cli/conf.d/20-xdebug.ini
COPY xdebug.ini /etc/php/8.0/cli/conf.d/20-xdebug.ini
COPY xdebug.ini /etc/php/8.1/cli/conf.d/20-xdebug.ini
COPY xdebug.ini /etc/php/8.2/cli/conf.d/20-xdebug.ini

COPY index.php /var/www/html

RUN chmod +x /usr/local/bin/start-container

ENTRYPOINT ["start-container"]

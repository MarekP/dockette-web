FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm
ENV USER_UID=1000
ENV USER_NAME=dfx
ENV USER_HOME=/home/dfx

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    useradd -ms /bin/bash -u $USER_UID $USER_NAME && \
    apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

# PHP
ENV PHP_MODS_DIR=/etc/php/8.5/mods-available
ENV PHP_CLI_DIR=/etc/php/8.5/cli/
ENV PHP_CLI_CONF_DIR=${PHP_CLI_DIR}/conf.d
ENV PHP_CGI_DIR=/etc/php/8.5/cgi/
ENV PHP_CGI_CONF_DIR=${PHP_CGI_DIR}/conf.d
ENV PHP_FPM_DIR=/etc/php/8.5/fpm/
ENV PHP_FPM_CONF_DIR=${PHP_FPM_DIR}/conf.d
ENV PHP_FPM_POOL_DIR=${PHP_FPM_DIR}/pool.d
ENV PHP_FPM_BIN=/usr/sbin/php-fpm8.5
ENV PHP_FPM_CONF=/etc/php/8.5/php-fpm.conf
ENV TZ=Europe/Prague

# INSTALLATION
RUN apt update && apt dist-upgrade -y && \
    # DEPENDENCIES #############################################################
    apt install -y wget curl apt-transport-https ca-certificates gnupg2 cron && \
    # KEYRINGS DIRECTORY #######################################################
    install -m 0755 -d /etc/apt/keyrings && \
    # PHP DEB.SURY.CZ ##########################################################
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/php.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/php.gpg] https://packages.sury.org/php/ trixie main" > /etc/apt/sources.list.d/php.list && \
    # NGINX ####################################################################
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/keyrings/nginx.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nginx.gpg] http://nginx.org/packages/debian/ trixie nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src [signed-by=/etc/apt/keyrings/nginx.gpg] http://nginx.org/packages/debian/ trixie nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt update && \
    apt install -y --no-install-recommends \
    nginx \
    supervisor \
    ghostscript \
    imagemagick \
    # php8.5-apc
    php8.5-apcu \
    php8.5-bz2 \
    php8.5-bcmath \
    php8.5-calendar \
    php8.5-cgi \
    php8.5-cli \
    php8.5-ctype \
    php8.5-curl \
    php8.5-fpm \
    php8.5-gettext \
    php8.5-gd \
    php8.5-intl \
    php8.5-imap \
    php8.5-imagick \
    php8.5-ldap \
    php8.5-mbstring \
    # php8.5-mongo
    php8.5-mysql \
    php8.5-pdo \
    php8.5-pgsql \
    php8.5-redis \
    php8.5-soap \
    php8.5-sqlite3 \
    php8.5-ssh2 \
    php8.5-tidy \
    php8.5-zip \
    # php8.5-xmlrpc \ # XMLRPC je v PHP 8+ zastaralé a často chybí
    php8.5-xsl && \
    # memcached zatím nemusí být v Sury repozitáři dostupný
    if apt-cache show php8.5-memcached > /dev/null 2>&1; then apt install -y --no-install-recommends php8.5-memcached; fi && \
    # COMPOSER #################################################################
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --2 && \
    # NGINX LOGS ###############################################################
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    # CLEAN UP #################################################################
    rm -f /etc/nginx/conf.d/default.conf && \
    apt clean -y && \
    apt autoclean -y && \
    apt remove -y wget gnupg2 && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

# PHP
ADD ./php/php-fpm.conf /etc/php/8.5/
ADD ./php/php.ini /etc/php/8.5/conf.d/

# NGINX
ADD ./nginx/nginx.conf /etc/nginx/
ADD ./nginx/mime.types /etc/nginx/
ADD ./nginx/sites.d /etc/nginx/sites.d

# WWW
ADD ./www /srv/www/

# SUPERVISOR
ADD ./supervisor/supervisord.conf /etc/supervisor/
ADD ./supervisor/services /etc/supervisor/conf.d/

# APPLICATION
WORKDIR /srv

# PORTS
EXPOSE 80
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod +x /usr/sbin/entrypoint.sh
CMD ["/usr/sbin/entrypoint.sh"]

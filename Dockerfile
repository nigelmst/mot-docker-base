FROM php:7.4-fpm-alpine

# Install system dependencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories
ARG APK_COMMON_DEPENDENCIES="bash busybox-suid curl dcron git libcap mysql-client unzip zip"
ARG FONTS="fontconfig ttf-dejavu"
RUN apk add --update --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/latest-stable/main $APK_COMMON_DEPENDENCIES $FONTS

# Install PHP extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
ARG PHP_EXTENSIONS="bcmath exif gd imagick intl opcache pcntl pdo_mysql pdo_sqlite zip"
RUN install-php-extensions $PHP_EXTENSIONS

# Install supervisord
COPY --from=ghcr.io/jbs-fm/supervisord:0.7.31 /usr/local/bin/supervisord /usr/local/bin/supervisord

# Install caddy
COPY --from=caddy:2.4.6 /usr/bin/caddy /usr/local/bin/caddy
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

# Install composer 2
COPY --from=composer:2.1.14 /usr/bin/composer /usr/local/bin/composer

# Install wkhtml
COPY --from=ghcr.io/surnet/alpine-wkhtmltopdf:3.10-0.12.6-full /bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
COPY --from=ghcr.io/surnet/alpine-wkhtmltopdf:3.10-0.12.6-full /bin/wkhtmltoimage /usr/local/bin/wkhtmltoimage

# Add & switch to non-root user: 'app'
ENV NON_ROOT_GROUP=${NON_ROOT_GROUP:-app}
ENV NON_ROOT_USER=${NON_ROOT_USER:-app}
RUN addgroup -S $NON_ROOT_GROUP && adduser -S $NON_ROOT_USER -G $NON_ROOT_GROUP
RUN addgroup $NON_ROOT_USER wheel

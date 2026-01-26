ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip libzip-dev \
    libpq-dev nodejs npm supervisor cron # Added supervisor and cron

# Install PHP extensions for Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# --- ADD BUN INSTALLATION HERE ---
RUN curl -fsSL https://bun.sh/install | bash \
    && mv /root/.bun/bin/bun /usr/local/bin/bun \
    && ln -sf /usr/local/bin/bun /usr/local/bin/bunx

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a system user to match Arch Linux UID (usually 1000)
ARG USER_ID=1000
RUN useradd -u ${USER_ID} -m -s /bin/bash laravel

# Set PATH for all users to include bun
ENV PATH="/usr/local/bin:$PATH"

# Copy custom PHP configuration
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini

# Create bunx symlink before switching users
RUN ln -sf /usr/local/bin/bun /usr/local/bin/bunx

# Copy supervisor configuration
COPY docker/php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy entrypoint script
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER laravel

# Install Laravel Installer
RUN composer global require laravel/installer

# Add PHP Composer global bin to PATH
ENV PATH="/home/laravel/.config/composer/vendor/bin:/home/laravel/.composer/vendor/bin:${PATH}"

WORKDIR /var/www

# Switch back to root to run supervisor
USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Use Debian 11 as the base image
FROM debian:11

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    DB_NAME=wordpress_db \
    DB_USER=wordpress_user \
    DB_PASSWORD=mypassword \
    DB_HOST=10.184.49.241 \
    APACHE_ROOT=/var/www/html/wordpress 

# Set timezone and install dependencies
RUN apt update && \
    apt install -y \
    nano \
    tzdata \
    apache2 \
    software-properties-common \
    mariadb-client \
    git \
    sudo \
    curl \
    php \
    php-cli \
    php-common \
    php-mysql \
    php-redis \
    php-snmp \
    php-xml \
    php-zip \
    php-mbstring \
    php-curl \
    libapache2-mod-php \
    lsb-release && \
    apt-get update && apt-get install -y git ca-certificates && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN rm -rf ${APACHE_ROOT} && mkdir -p ${APACHE_ROOT}


RUN apt-get update && apt-get install -y curl && \
    curl -sSL https://github.com/vishnubob/wait-for-it/raw/master/wait-for-it.sh -o /usr/local/bin/wait-for-it && \
    chmod +x /usr/local/bin/wait-for-it

# Enable Apache rewrite module
RUN a2enmod rewrite

# Clone WordPress repository with retry logic
RUN git clone --depth=1 --branch main https://github.com/NarpaviGomathi/WordPress.git ${APACHE_ROOT} || \
    (echo "🔄 Retrying clone after failure..." && sleep 5 && git clone --depth=1 --branch main https://github.com/NarpaviGomathi/WordPress.git ${APACHE_ROOT}) && \
    chown -R www-data:www-data ${APACHE_ROOT} && \
    chmod -R 755 ${APACHE_ROOT}

RUN cp ${APACHE_ROOT}/wp-config-sample.php ${APACHE_ROOT}/wp-config.php && \
    sed -i "s/database_name_here/${DB_NAME}/g" ${APACHE_ROOT}/wp-config.php && \
    sed -i "s/username_here/${DB_USER}/g" ${APACHE_ROOT}/wp-config.php && \
    sed -i "s/password_here/${DB_PASSWORD}/g" ${APACHE_ROOT}/wp-config.php && \
    sed -i "s/localhost/${DB_HOST}/g" ${APACHE_ROOT}/wp-config.php && \
    echo "define( 'FS_METHOD', 'direct' );" >> ${APACHE_ROOT}/wp-config.php && \
    echo "define( 'WP_DEBUG', true );" >> ${APACHE_ROOT}/wp-config.php && \
    sed -i "s/^\$table_prefix = .*/\$table_prefix = 'wp_';/" ${APACHE_ROOT}/wp-config.php

# Configure Apache Virtual Host
RUN echo "ServerName 10.184.49.241" >> /etc/apache2/apache2.conf && \
    echo '<VirtualHost *:80>' > /etc/apache2/sites-available/wordpress.com.conf && \
    echo '    ServerName 10.184.49.241' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '    DocumentRoot /var/www/html/wordpress' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '    <Directory "/var/www/html/wordpress">' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '    ErrorLog ${APACHE_LOG_DIR}/wordpress.com-error.log' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '    CustomLog ${APACHE_LOG_DIR}/wordpress.com-access.log combined' >> /etc/apache2/sites-available/wordpress.com.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/wordpress.com.conf

RUN wait-for-it ${DB_HOST}:3306 --timeout=30 --strict -- \
    echo "DB_HOST: ${DB_HOST}" && \
    echo "DB_USER: ${DB_USER}" && \
    echo "DB_PASSWORD: ${DB_PASSWORD}" && \
    mysql --protocol=TCP -h ${DB_HOST} -u root -p${DB_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DB_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    echo "ALTER USER 'root'@'%' IDENTIFIED BY '${DB_PASSWORD}'; \
           GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; \
           FLUSH PRIVILEGES; \
           DROP DATABASE IF EXISTS ${DB_NAME}; \
           CREATE DATABASE ${DB_NAME}; \
           CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}'; \
           GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%'; \
           FLUSH PRIVILEGES;" | mysql --protocol=TCP -h ${DB_HOST} -u root -p${DB_PASSWORD}

# Show tables in the database (for debugging purposes)
RUN echo "SHOW TABLES FROM ${DB_NAME};" | mysql -h ${DB_HOST} -u root -p${DB_PASSWORD}


# Enable Apache site and modules
RUN a2enmod rewrite \
    && a2ensite wordpress.com.conf \
    && apachectl -t \
    && apache2ctl configtest 
    
# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]  

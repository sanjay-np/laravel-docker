#!/bin/bash
set -e

# Create multiple databases based on an environment variable
if [ -n "$MYSQL_ADDITIONAL_DATABASES" ]; then
    echo "Creating additional databases: $MYSQL_ADDITIONAL_DATABASES"
    for db in $(echo $MYSQL_ADDITIONAL_DATABASES | tr ',' ' '); do
        mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$db\`;"
        mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$db\`.* TO '$MYSQL_USER'@'%';"
    done
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
fi

# Grant the laravel user administrative privileges so they can create databases via phpMyAdmin
echo "Granting administrative privileges to $MYSQL_USER..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%'; FLUSH PRIVILEGES;"

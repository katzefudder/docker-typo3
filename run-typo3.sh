#!/bin/bash

DB_HOST=${DB_PORT_3306_TCP_ADDR:-${DB_HOST}}
DB_HOST=${DB_1_PORT_3306_TCP_ADDR:-${DB_HOST}}
DB_PORT=${DB_PORT_3306_TCP_PORT:-${DB_PORT}}
DB_PORT=${DB_1_PORT_3306_TCP_PORT:-${DB_PORT}}

if [ "$DB_PASS" = "**ChangeMe**" ] && [ -n "$DB_1_ENV_MYSQL_PASS" ]; then
    DB_PASS="$DB_1_ENV_MYSQL_PASS"
fi

echo "=> Using the following MySQL/MariaDB configuration:"
echo "========================================================================"
echo "      Database Host Address:  $DB_HOST"
echo "      Database Port number:   $DB_PORT"
echo "      Database Name:          $DB_NAME"
echo "      Database Username:      $DB_USER"
echo "========================================================================"
echo "=> Waiting for database ..."

if [ ! -f /app/typo3conf/LocalConfiguration.php ]
then
	php /app/Packages/Libraries/helhum/typo3-console/Scripts/typo3cms install:setup --non-interactive \
    --database-user-name="admin" --database-user-password="$DB_PASS" \
    --database-host-name="$DB_HOST" --database-port="$DB_PORT" --database-name="$DB_NAME" \
    --admin-user-name="admin" --admin-password="password" \
    --site-name="TYPO3 Demo Installation" --site-setup-type="createsite"

    echo "Set permissions for /app folder ..."
    chown www-data:www-data -R /app/fileadmin /app/typo3temp /app/uploads
fi

# Start apache in foreground if no arguments are given
if [ $# -eq 0 ]
then
    apachectl -D FOREGROUND
fi

#!/bin/bash
set -e

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-majesticflame}"
DB_PASSWORD="${DB_PASSWORD:-1234}"
DB_DATABASE="${DB_DATABASE:-ccio}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-rootpassword}"
MYSQL_DATADIR="${MYSQL_DATADIR:-/var/lib/mysql}"

shutdown() {
    pm2 stop all >/dev/null 2>&1 || true
    mysqladmin --protocol=socket -uroot shutdown >/dev/null 2>&1 || \
        mysqladmin --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown >/dev/null 2>&1 || true
}
trap shutdown TERM INT

mysql_root() {
    mysql --protocol=socket -uroot "$@" 2>/tmp/mysql-root.err || \
        mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" "$@"
}

mkdir -p /home/Shinobi && cp -a -R /opt/shinobi/. /home/Shinobi

if [ ! -e "/home/Shinobi/conf.json" ]; then
    cp /home/Shinobi/conf.sample.json /home/Shinobi/conf.json
fi

if [ ! -e "/home/Shinobi/super.json" ]; then
    cp /home/Shinobi/super.sample.json /home/Shinobi/super.json
    echo "Default Superuser : admin@shinobi.video"
    echo "Default Password : admin"
    echo "* You can edit these settings in \"super.json\" located in the Shinobi directory."
fi

if [ "$SHINOBI_UPDATE" = "true" ]; then
    echo "Updating Shinobi..."
    git reset --hard
    git pull --rebase
fi

if [ ! -d "${MYSQL_DATADIR}/mysql" ]; then
    echo "Initializing local MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir="${MYSQL_DATADIR}" >/dev/null
fi

echo "Starting local MariaDB..."
chown -R mysql:mysql "${MYSQL_DATADIR}"
mysqld_safe --datadir="${MYSQL_DATADIR}" --bind-address="${DB_HOST}" --port="${DB_PORT}" &
MYSQL_PID=$!

until mysqladmin --protocol=socket ping >/dev/null 2>&1; do
    >&2 echo "MariaDB is currently unavailable - retrying..."
    sleep 1
done

mysql_root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_DATABASE}\`.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

TABLE_COUNT=$(mysql_root -Nse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_DATABASE}';")
if [ "${TABLE_COUNT}" = "0" ] && [ -f "/home/Shinobi/sql/framework.sql" ]; then
    echo "Importing Shinobi database schema..."
    mysql_root "${DB_DATABASE}" < /home/Shinobi/sql/framework.sql
fi

>&2 echo ""
##############

DB_CONFIG=$(cat <<EOF
{
    "host": "${DB_HOST}",
    "user": "${DB_USER}",
    "password": "${DB_PASSWORD}",
    "database": "${DB_DATABASE}",
    "port": ${DB_PORT}
}
EOF
)
echo "Setting Database"
echo $DB_CONFIG

node tools/modifyConfiguration.js addToConfig="{\"db\": $DB_CONFIG}"

pm2 flush
pm2 start camera.js
pm2 logs --lines 200 &
PM2_LOGS_PID=$!

wait "$PM2_LOGS_PID"
wait "$MYSQL_PID"

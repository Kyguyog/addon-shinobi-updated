#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SHINOBI_HOME=/data/shinobi
MYSQL_DATADIR=/data/mysql

option() {
    local key="$1"
    local fallback="$2"

    if [ -f "${CONFIG_PATH}" ]; then
        jq -r --arg key "${key}" --arg fallback "${fallback}" '.[$key] // $fallback' "${CONFIG_PATH}"
    else
        echo "${fallback}"
    fi
}

LOG_LEVEL="$(option log_level "${LOG_LEVEL:-info}")"
SUPER_USERNAME="$(option super_username "${SUPER_USERNAME:-admin@shinobi.video}")"
SUPER_PASSWORD="$(option super_password "${SUPER_PASSWORD:-admin}")"
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER="$(option mysql_username "${DB_USER:-shinobi}")"
DB_PASSWORD="$(option mysql_password "${DB_PASSWORD:-sh1n0b1}")"
DB_DATABASE="$(option mysql_database "${DB_DATABASE:-shinobi}")"
MYSQL_ROOT_PASSWORD="$(option mysql_root_password "${MYSQL_ROOT_PASSWORD:-rootpassword}")"
SHINOBI_UPDATE="$(option shinobi_update "${SHINOBI_UPDATE:-false}")"

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

sql_string() {
    printf "%s" "$1" | sed "s/'/''/g"
}

sql_identifier() {
    printf "%s" "$1" | sed 's/`/``/g'
}

echo "Starting Shinobi add-on with log level: ${LOG_LEVEL}"

mkdir -p "${SHINOBI_HOME}" "${MYSQL_DATADIR}"
cp -a -R /opt/shinobi/. "${SHINOBI_HOME}"
cd "${SHINOBI_HOME}"

if [ ! -e "${SHINOBI_HOME}/conf.json" ]; then
    cp "${SHINOBI_HOME}/conf.sample.json" "${SHINOBI_HOME}/conf.json"
fi

if [ ! -e "${SHINOBI_HOME}/super.json" ]; then
    cp "${SHINOBI_HOME}/super.sample.json" "${SHINOBI_HOME}/super.json"
    echo "Default Superuser : ${SUPER_USERNAME}"
    echo "Default Password : ${SUPER_PASSWORD}"
    echo "* You can edit these settings in \"super.json\" located in the Shinobi directory."
fi

SUPER_PASSWORD_HASH="$(printf "%s" "${SUPER_PASSWORD}" | md5sum | awk '{print $1}')"
jq \
    -n \
    --arg mail "${SUPER_USERNAME}" \
    --arg pass "${SUPER_PASSWORD_HASH}" \
    '[{"mail": $mail, "pass": $pass}]' > "${SHINOBI_HOME}/super.json.tmp"
mv "${SHINOBI_HOME}/super.json.tmp" "${SHINOBI_HOME}/super.json"

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

DB_USER_SQL="$(sql_string "${DB_USER}")"
DB_PASSWORD_SQL="$(sql_string "${DB_PASSWORD}")"
DB_DATABASE_SQL="$(sql_string "${DB_DATABASE}")"
DB_DATABASE_IDENTIFIER="$(sql_identifier "${DB_DATABASE}")"
MYSQL_ROOT_PASSWORD_SQL="$(sql_string "${MYSQL_ROOT_PASSWORD}")"

mysql_root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD_SQL}';
CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE_IDENTIFIER}\`;
CREATE USER IF NOT EXISTS '${DB_USER_SQL}'@'%' IDENTIFIED BY '${DB_PASSWORD_SQL}';
ALTER USER '${DB_USER_SQL}'@'%' IDENTIFIED BY '${DB_PASSWORD_SQL}';
GRANT ALL PRIVILEGES ON \`${DB_DATABASE_IDENTIFIER}\`.* TO '${DB_USER_SQL}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

TABLE_COUNT=$(mysql_root -Nse "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_DATABASE_SQL}';")
if [ "${TABLE_COUNT}" = "0" ] && [ -f "${SHINOBI_HOME}/sql/framework.sql" ]; then
    echo "Importing Shinobi database schema..."
    mysql_root "${DB_DATABASE}" < "${SHINOBI_HOME}/sql/framework.sql"
fi

>&2 echo ""
##############

DB_CONFIG="$(jq -nc \
    --arg host "${DB_HOST}" \
    --arg user "${DB_USER}" \
    --arg password "${DB_PASSWORD}" \
    --arg database "${DB_DATABASE}" \
    --argjson port "${DB_PORT}" \
    '{host: $host, user: $user, password: $password, database: $database, port: $port}')"
echo "Setting Database"
echo $DB_CONFIG

node tools/modifyConfiguration.js addToConfig="{\"db\": $DB_CONFIG}"

pm2 flush
pm2 start camera.js
pm2 logs --lines 200 &
PM2_LOGS_PID=$!

wait "$PM2_LOGS_PID"
wait "$MYSQL_PID"

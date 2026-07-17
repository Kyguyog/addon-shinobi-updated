#!/usr/bin/env bashio
# ==============================================================================
# Community Hass.io Add-ons: Shinobi
# Ensures the database structure is loaded into MySQL
# ==============================================================================
# shellcheck disable=SC1091

declare host
declare username
declare password
declare database
declare port
declare numberOfTables

if bashio::config.true 'mysql'; then
    host=$(bashio::config 'mysql_host')
    username=$(bashio::config 'mysql_username')
    password=$(bashio::config 'mysql_password')
    database=$(bashio::config 'mysql_database')
    port=$(bashio::config 'mysql_port')

    numberOfTables=$(
        mysql -h "${host}" -u "${username}" -p"${password}" -P "${port}" \
            "${database}" -N -B -e "show tables;" | wc -l
    )

    if [[ "${numberOfTables}" -eq 0 ]]; then
        mysql -h "${host}" -u "${username}" -p"${password}" -P "${port}" \
            "${database}" < "/opt/shinobi/sql/tables.sql" ||
                bashio::exit.nok "Error while importing database table structure!"
    fi
fi

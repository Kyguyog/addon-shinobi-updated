#!/usr/bin/env bashio
# ==============================================================================
# Community Hass.io Add-ons: Shinobi
# Ensures the super user account credentials are configured
# ==============================================================================
# shellcheck disable=SC1091

declare CONFIG
declare username
declare password

CONFIG=$(</opt/shinobi/super.json)
username=$(bashio::config 'super_username')
password=$(bashio::config 'super_password')
password=$(echo -n "${password}" | md5sum | sed -e 's/  -$//')

CONFIG=$(bashio::jq "${CONFIG}" ".[0].mail=\"${username}\"")
CONFIG=$(bashio::jq "${CONFIG}" ".[0].pass=\"${password}\"")

echo "${CONFIG}" > /opt/shinobi/super.json

#!/usr/bin/env bashio
# ==============================================================================
# Community Hass.io Add-ons: Shinobi
# Ensures the SSL settings are configured
# ==============================================================================
# shellcheck disable=SC1091

declare CONFIG
declare certfile
declare keyfile

CONFIG=$(</opt/shinobi/conf.json)

if bashio::config.true 'ssl'; then
    CONFIG=$(bashio::jq "${CONFIG}" ".ssl={}")

    certfile=$(bashio::config 'certfile')
    CONFIG=$(bashio::jq "${CONFIG}" ".ssl.cert=\"/ssl/${certfile}\"")

    keyfile=$(bashio::config 'keyfile')
    CONFIG=$(bashio::jq "${CONFIG}" ".ssl.key=\"/ssl/${keyfile}\"")
else
    CONFIG=$(bashio::jq "${CONFIG}" "del(.ssl)")
fi

echo "${CONFIG}" > /opt/shinobi/conf.json

#!/usr/bin/env bashio
# ==============================================================================
# Community Hass.io Add-ons: Shinobi
# Ensures the mail settings and credentials are configured
# ==============================================================================
# shellcheck disable=SC1091

declare CONFIG
declare service
declare username
declare password
declare host
declare port

CONFIG=$(</opt/shinobi/conf.json)

service=$(bashio::config 'mail_service')
username=$(bashio::config 'mail_username')
password=$(bashio::config 'mail_password')

CONFIG=$(bashio::jq "${CONFIG}" ".mail={\"auth\": {}}");

if [[ "${service}" = "gmail" ]]; then
    CONFIG=$(bashio::jq "${CONFIG}" ".mail.service=\"gmail\"")
else
    host=$(bashio::config 'mail_host')
    CONFIG=$(bashio::jq "${CONFIG}" ".mail.host=\"${host}\"")
    
    port=$(bashio::config 'mail_port')
    CONFIG=$(bashio::jq "${CONFIG}" ".mail.port=${port}")

    if bashio::config.true 'mail_secure'; then
        CONFIG=$(bashio::jq "${CONFIG}" ".mail.secure=true")
    else
        CONFIG=$(bashio::jq "${CONFIG}" ".mail.secure=false")
    fi

    if bashio::config.false 'mail_cert_verify'; then
        CONFIG=$(bashio::jq "${CONFIG}" ".mail.tls={\"rejectUnauthorized\": false}")
    fi
fi

CONFIG=$(bashio::jq "${CONFIG}" ".mail.auth.user=\"${username}\"")
CONFIG=$(bashio::jq "${CONFIG}" ".mail.auth.pass=\"${password}\"")

echo "${CONFIG}" > /opt/shinobi/conf.json

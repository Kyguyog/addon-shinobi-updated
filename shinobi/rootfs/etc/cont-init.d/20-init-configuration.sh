#!/usr/bin/env bashio
# ==============================================================================
# Community Hass.io Add-ons: Shinobi
# Creates initial Shinobi configuration in case it is non-existing
# ==============================================================================
# shellcheck disable=SC1091

declare CONFIG

if ! bashio::fs.directory_exists '/share/shinobi'; then
    mkdir '/share/shinobi'
fi

if ! bashio::fs.file_exists '/data/shinobi.sqlite'; then
    cp /opt/shinobi/sql/shinobi.sample.sqlite /data/shinobi.sqlite
fi

if ! bashio::fs.file_exists '/data/conf.json'; then

    CONFIG=$(</opt/shinobi/conf.sample.json)

    CONFIG=$(bashio::jq "${CONFIG}" ".cpuUsageMarker=\"cpu\"")
    CONFIG=$(bashio::jq "${CONFIG}" ".port=80")
    CONFIG=$(bashio::jq "${CONFIG}" ".videosDir=\"/share/shinobi/\"")

    echo "${CONFIG}" > /data/conf.json
fi

if ! bashio::fs.file_exists '/data/super.json'; then
    cp /opt/shinobi/super.sample.json /data/super.json
fi

if bashio::fs.file_exists '/data/motion.conf.json'; then
    bashio::log.warning 'motion.conf.json is no longer required for motion. Recommend deleting.'
fi

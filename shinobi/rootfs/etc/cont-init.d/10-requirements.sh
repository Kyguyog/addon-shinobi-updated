#!/usr/bin/env bashio
# ==============================================================================
# Community Hass.io Add-ons: Shinobi
# This files check if all user configuration requirements are met
# ==============================================================================
# shellcheck disable=SC1091

# Check SSL requirements, if enabled
if bashio::config.true 'ssl'; then
    if ! bashio::config.has_value 'certfile'; then
        bashio::exit.nok 'SSL is enabled, but no certfile was specified'
    fi

    if ! bashio::config.has_value 'keyfile'; then
        bashio::exit.nok 'SSL is enabled, but no keyfile was specified'
    fi

    if ! bashio::fs.file_exists "/ssl/$(bashio::config 'certfile')"; then
        bashio::exit.nok 'The configured certfile is not found'
    fi

    if ! bashio::fs.file_exists "/ssl/$(bashio::config 'keyfile')"; then
        bashio::exit.nok 'The configured keyfile is not found'
    fi
fi

ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
# hadolint ignore=DL3003,DL3016
RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base \
        g++ \
        jpeg-dev \
        make \
        openssl-dev \
        pkgconf \
        python2-dev \
        git \
    && apk add --no-cache \
        npm \
        yarn \
        ffmpeg \
        mysql-client \
        nodejs \
        python2 \
        socat \
        sqlite \
        ttf-freefont \
        x264 \
        x265 \
    && git clone -b master --single-branch \
        https://gitlab.com/Shinobi-Systems/Shinobi.git /opt/shinobi/ \
    && git -C /opt/shinobi checkout e9e33a4b592fb12911e4e78de8c578bb5f1bedef \
    && git -C /opt/shinobi reflog expire --expire=now --all \
    && git -C /opt/shinobi gc --prune=now --aggressive \
    && cd /opt/shinobi \
    && yarn add mysql sqlite3 --ignore-engines \
    && yarn install --ignore-engines \
    && apk del --purge .build-dependencies

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Shinobi" \
    io.hass.description="Beautiful and feature-rich CCTV/NVR for your camera's" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Rob Landry <rob@landry.me>" \
    org.label-schema.description="Beautiful and feature-rich CCTV/NVR for your camera's" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Shinobi" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://community.home-assistant.io/t/community-hass-io-add-on-shinobi-pro/49767?u=frenck" \
    org.label-schema.usage="https://github.com/roblandry/addon-shinobi/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/roblandry/addon-shinobi" \
    org.label-schema.vendor="Community Hass.io Add-ons"

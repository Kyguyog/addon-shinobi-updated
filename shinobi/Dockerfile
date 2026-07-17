ARG BUILD_FROM
# For security and stability, we build from the Home Assistant base image
# hadolint ignore=DL3006
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy root filesystem early so we can fix permissions
COPY rootfs /

# 1. FIX SCRIPT PERMISSIONS: Make sure s6-overlay can execute the setup scripts
RUN chmod +x -R /etc/cont-init.d/ 2>/dev/null || true \
    && chmod +x -R /etc/services.d/ 2>/dev/null || true

# 2. INSTALL DEPENDENCIES & SHINOBI CORE
# We fetch nodejs from Alpine Edge to bypass the deprecated Node v12 engine error
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
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
        nodejs \
    && apk add --no-cache \
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

# Build arguments for Hass.io metadata
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Label details
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Your Name" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Community Home Assistant Add-ons" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}"

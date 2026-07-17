ARG BASE_IMAGE=node:22-bookworm-slim
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

ARG SHINOBI_BRANCH=dev
ARG BUILD_VERSION=dev
ARG BUILD_ARCH=amd64

LABEL \
    io.hass.name="Shinobi Pro" \
    io.hass.description="Shinobi CCTV/NVR with local MariaDB" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="app" \
    io.hass.arch="${BUILD_ARCH}"

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    ffmpeg \
    default-mysql-server \
    jq \
    procps \
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

RUN git clone --branch $SHINOBI_BRANCH https://gitlab.com/Shinobi-Systems/Shinobi.git /opt/shinobi

WORKDIR /opt/shinobi
RUN npm install && npm install pm2 -g

WORKDIR /data/shinobi

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

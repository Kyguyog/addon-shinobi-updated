#!/bin/bash

echo "Creating the local development data directory..."
mkdir -p $HOME/ShinobiAddon

echo "Building and running the single-container Shinobi CCTV system for local development..."
docker compose -f docker-compose-main.yml up -d --build

echo "Shinobi CCTV should now be accessible on port 8080."

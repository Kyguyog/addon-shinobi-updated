#!/bin/bash

echo "Creating and setting permissions for the MySQL data directory..."
mkdir -p $HOME/ShinobiSQL
sudo chown -R 999:999 $HOME/ShinobiSQL
mkdir -p $HOME/Shinobi
sudo chown -R $USER:$USER $HOME/Shinobi

echo "Building and running the single-container Shinobi CCTV system..."
docker compose -f docker-compose-main.yml up -d --build

echo "Shinobi CCTV should now be accessible on port 8080."

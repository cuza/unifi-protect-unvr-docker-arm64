#!/usr/bin/with-contenv bashio

set -e

bashio::log.info "Starting UniFi Protect UNVR addon..."

# Read configuration from Home Assistant
STORAGE_DISK=$(bashio::config 'storage_disk')
DEVICE_TYPE=$(bashio::config 'device_type')
DEBUG=$(bashio::config 'debug')
DEBUG_STORAGE=$(bashio::config 'debug_storage')
DEBUG_UNIFI_CORE=$(bashio::config 'debug_unifi_core')

# Log configuration
bashio::log.info "Storage disk: ${STORAGE_DISK}"
bashio::log.info "Device type: ${DEVICE_TYPE}"
bashio::log.info "Debug mode: ${DEBUG}"

# Export environment variables for the container
export STORAGE_DISK
export DEVICE="${DEVICE_TYPE}"
export DEBUG
export DEBUG_STORAGE
export DEBUG_UNIFI_CORE
export container=docker

# Map Home Assistant directories to container paths
# /data (addon data) can be used for video storage
# /media (addon media) can be used for larger video storage
# Both directories are mapped in config.json

# Create symlinks if needed for storage directories
if [ ! -L /srv ] && [ ! -d /srv ]; then
    bashio::log.info "Setting up storage directories..."
    # Use /media for video storage (larger capacity)
    ln -sf /media/unifi-protect/srv /srv || true
    mkdir -p /media/unifi-protect/srv
fi

if [ ! -d /data/unifi-protect ]; then
    mkdir -p /data/unifi-protect
fi

if [ ! -d /persistent/unifi-protect ]; then
    mkdir -p /persistent || true
    mkdir -p /persistent/unifi-protect || true
fi

bashio::log.info "Starting systemd..."

# Start systemd (existing container entrypoint)
exec /lib/systemd/systemd

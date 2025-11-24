#!/usr/bin/with-contenv bashio
# bashio is the Home Assistant addon helper library
# See: https://github.com/hassio-addons/bashio

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
    # Create target directory first
    mkdir -p /media/unifi-protect/srv
    # Use /media for video storage (larger capacity)
    if ! ln -sf /media/unifi-protect/srv /srv; then
        bashio::log.warning "Failed to create symlink for /srv, using directory instead"
        mkdir -p /srv
    fi
fi

if [ ! -d /data/unifi-protect ]; then
    if ! mkdir -p /data/unifi-protect; then
        bashio::log.error "Failed to create /data/unifi-protect directory"
    fi
fi

if [ ! -d /persistent/unifi-protect ]; then
    mkdir -p /persistent 2>/dev/null || bashio::log.warning "Failed to create /persistent directory"
    mkdir -p /persistent/unifi-protect 2>/dev/null || bashio::log.warning "Failed to create /persistent/unifi-protect directory"
fi

bashio::log.info "Starting systemd..."

# Start systemd (existing container entrypoint)
exec /lib/systemd/systemd

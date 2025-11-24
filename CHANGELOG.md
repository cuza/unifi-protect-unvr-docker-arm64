# Changelog

All notable changes to this Home Assistant addon will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.8.3] - 2024-11-23

### Added
- Initial release of UniFi Protect UNVR as Home Assistant addon
- Support for ARM64 (aarch64) architecture
- Configuration options for storage disk, device type, and debug modes
- Automatic directory mapping for Home Assistant config and media directories
- Comprehensive documentation for installation and configuration
- Support for UNVR, UNVR_PRO, and ENVR device emulation
- Host networking support for full functionality
- Privileged mode support for systemd and hardware access
- **Builds from source:** Addon builds UniFi Protect image from source during installation to avoid distributing copyrighted UniFi content (complies with licensing requirements)

### Features
- Full UniFi Protect UNVR functionality within Home Assistant
- Support for UniFi cameras and third-party ONVIF cameras
- Built-in PostgreSQL 14 database
- Video storage management via Home Assistant media directory
- Camera firmware management
- Remote access capabilities (with proper network configuration)
- RTSP streaming support
- Debug logging options for troubleshooting

### Important Notes
- **First installation takes 30-60 minutes:** The addon downloads UniFi firmware and builds the complete stack from source. This is a one-time process during initial installation.
- **No pre-built images:** To comply with UniFi's licensing, the addon does not use pre-built Docker images. It builds everything from official UniFi sources during installation.

### Requirements
- Home Assistant OS or Supervised installation
- ARM64 (aarch64) architecture only
- Minimum 4GB RAM (8GB recommended)
- Minimum 100GB storage for video recordings
- IPv6 enabled on host system
- No port conflicts on 80, 443, and UniFi Protect ports (7441-7552)

### Known Limitations
- ARM64 architecture only (no x86/amd64 support)
- Requires privileged mode for systemd operation
- Requires host networking for full functionality
- Remote access requires primary interface named 'enp0s2'
- Auto-updates not supported (must update via addon updates)
- Single storage disk supported

### Documentation
- Complete installation guide
- Detailed configuration instructions
- Network setup requirements
- Troubleshooting guide
- Migration guide from standalone Docker
- Integration examples with Home Assistant

## [Unreleased]

### Planned Features
- Home Assistant entity integration (cameras, sensors)
- HACS support for easier installation
- Multi-disk storage support
- Automatic backup integration
- Person detection events
- Doorbell button event integration
- Motion detection binary sensors

---

## Version Alignment

This addon follows the UniFi Protect version packaged in the container. The addon version matches the UniFi Protect UNVR firmware version used.

- Addon version 5.8.3 = UniFi Protect UNVR firmware v5.8.3

## Upgrade Notes

### From Standalone Docker to Addon

If migrating from the standalone Docker version:
1. Backup all data before migration
2. Copy storage directories to Home Assistant media directory
3. Configure addon with same settings as docker-compose.override.yml
4. Verify all cameras and recordings after migration

### Important Upgrade Information

- **Never downgrade** - UniFi Protect database migrations are one-way only
- **Backup before updates** - Always backup data before updating
- **Camera firmware** - May auto-update when Protect updates
- **Breaking changes** - Check changelog before updating

## Support

For issues, questions, and feature requests:
- [GitHub Issues](https://github.com/dciancu/unifi-protect-unvr-docker-arm64/issues)
- [GitHub Discussions](https://github.com/dciancu/unifi-protect-unvr-docker-arm64/discussions)
- [Main Repository](https://github.com/dciancu/unifi-protect-unvr-docker-arm64)

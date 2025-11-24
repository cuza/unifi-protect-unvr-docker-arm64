# UniFi Protect UNVR Home Assistant Addon

Run UniFi Protect UNVR in Docker on ARM64 hardware within Home Assistant.

This addon allows you to run a complete UniFi Protect UNVR system as a Home Assistant addon, providing video surveillance and camera management capabilities directly within your Home Assistant installation.

## About

This addon packages the UniFi Protect UNVR Docker container for easy installation and management within Home Assistant. It maintains full compatibility with the standalone Docker version while providing seamless integration with Home Assistant's addon system.

### Features

- Full UniFi Protect UNVR functionality
- Support for UniFi cameras and third-party ONVIF cameras
- Hardware emulation for UNVR, UNVR Pro, and ENVR devices
- Built-in PostgreSQL 14 database
- Video storage management
- Camera firmware management
- Remote access capabilities (with proper network configuration)

## Installation

1. Add this repository to your Home Assistant addon store
2. Install the "UniFi Protect UNVR" addon
3. **Note:** The addon will build the UniFi Protect image from source during installation to avoid distributing copyrighted UniFi content. This initial build may take 30-60 minutes depending on your hardware.
4. Configure the addon (see Configuration section)
5. Start the addon
6. Navigate to the addon's web interface (typically https://your-ha-ip:443)
7. Complete the initial UniFi Protect setup

## Configuration

The addon requires minimal configuration to get started:

```yaml
storage_disk: "/dev/sda"
device_type: "UNVR"
debug: false
debug_storage: false
debug_unifi_core: false
```

For detailed configuration instructions, please see the [Documentation](DOCS.md) tab.

## Important Requirements

- **Minimum 4GB RAM** - UniFi Protect requires at least 4GB of RAM to run properly
- **ARM64 Architecture** - This addon only supports ARM64 systems (aarch64)
- **Storage Disk** - You must specify a valid storage disk path
- **Privileged Mode** - Required for systemd and hardware access
- **Host Networking** - Required for full functionality including remote access
- **IPv6 Support** - Must be enabled on the host (even if not actively used)

## Support

For issues, questions, and detailed documentation, please visit:
- [Main Project Repository](https://github.com/dciancu/unifi-protect-unvr-docker-arm64)
- [Documentation](DOCS.md)
- [Changelog](CHANGELOG.md)

## Disclaimer

This is an experimental project. Use at your own risk.  
This project is not associated with UniFi and/or Ubiquiti in any way.

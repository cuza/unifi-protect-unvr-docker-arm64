# UniFi Protect UNVR Addon Documentation

## Overview

This Home Assistant addon runs UniFi Protect UNVR in a Docker container, allowing you to manage UniFi cameras and video surveillance directly within your Home Assistant installation.

## Prerequisites

Before installing this addon, ensure your system meets these requirements:

### Hardware Requirements

- **Architecture**: ARM64 (aarch64) only
- **RAM**: Minimum 4GB (8GB recommended)
- **Storage**: At least 100GB available for video storage
- **CPU**: Multi-core ARM64 processor (tested on Raspberry Pi 4)

### System Requirements

- Home Assistant OS or Supervised installation
- IPv6 enabled on the host system (even if not routed)
- No other services using ports 80, 443, or UniFi Protect ports (7441-7552)
- Kernel parameter: `systemd.unified_cgroup_hierarchy=0` (if encountering systemd errors)

## Installation

1. Navigate to **Settings** → **Add-ons** → **Add-on Store**
2. Click the menu (⋮) and select **Repositories**
3. Add this repository URL
4. Find "UniFi Protect UNVR" in the add-on list
5. Click on the addon and press **Install**

## Configuration

### Basic Configuration

The addon provides the following configuration options:

#### `storage_disk` (required)

The device path for video storage. This must be a valid block device accessible from within the container.

**Examples:**
- `/dev/sda` - First SATA disk
- `/dev/mmcblk0` - SD card
- `/dev/nvme0n1` - NVMe drive

**Important:** Ensure the device is accessible within the container. You may need to mount the device on the host first.

#### `device_type` (required)

The UniFi device type to emulate. Options:
- `UNVR` - Standard UniFi Video Recorder (default)
- `UNVR_PRO` - UniFi Video Recorder Pro
- `ENVR` - Enterprise Video Recorder

**Default:** `UNVR`

#### `debug` (optional)

Enable comprehensive debug logging. When enabled, activates all debug options.

**Default:** `false`

#### `debug_storage` (optional)

Enable detailed storage operation logging. Logs are written to `/var/log/storage_disk_debug.log`.

**Default:** `false`

#### `debug_unifi_core` (optional)

Enable debug log level for unifi-core service.

**Default:** `false`

### Example Configuration

```yaml
storage_disk: "/dev/sda"
device_type: "UNVR"
debug: false
debug_storage: false
debug_unifi_core: false
```

## Storage Configuration

### Storage Paths

The addon uses Home Assistant's standard directory mappings:

- `/data` - Addon data directory (for configuration and database)
- `/media` - Media directory (recommended for video storage)

Video storage is located at `/srv` within the container, which should be backed by adequate storage capacity.

### Storage Disk Setup

The `storage_disk` parameter must point to a valid block device:

1. **Identify your storage device:**
   ```bash
   lsblk
   ```

2. **Ensure the device is accessible** (may require mounting on host)

3. **Configure the addon** with the device path

### Storage Requirements

- **Minimum capacity**: 100GB (some cameras require this to adopt)
- **Recommended capacity**: 500GB+ depending on camera count and retention needs
- **Performance**: SSD/NVMe recommended for better performance

## Network Configuration

### Host Networking

This addon requires **host networking** (`host_network: true`) for full functionality:

- Camera adoption
- RTSP streaming
- Remote access via UniFi Cloud
- mDNS/Bonjour discovery

### Required Ports

When using host networking, the following ports are used:

| Port | Protocol | Purpose |
|------|----------|---------|
| 80 | TCP | Web interface redirect |
| 443 | TCP | Web interface (HTTPS) |
| 7441 | TCP | Devices management |
| 7445 | TCP | Camera HTTPS/WSS |
| 7446 | TCP | RTSP feeds |
| 7447 | TCP | RTSP feeds |
| 7451 | TCP | Camera management |
| 7550 | TCP | Playback |
| 7552 | TCP | Events |
| 10001 | UDP | Device discovery |

### Network Interface Configuration

For remote access via UniFi Cloud to work properly, the primary network interface should be named `enp0s2`.

**To configure on the host machine:**

1. Create `/etc/systemd/network/98-enp0s2.link`:
   ```
   [Match]
   MACAddress=xx:xx:xx:xx:xx:xx
   
   [Link]
   Name=enp0s2
   ```
   Replace `xx:xx:xx:xx:xx:xx` with your actual MAC address.

2. Update initramfs:
   ```bash
   sudo update-initramfs -u
   ```

3. Reboot the host machine

4. Update firewall rules to reflect the new interface name

**Warning:** This changes your primary network interface name. Update all network configurations and firewall rules before rebooting.

### IPv6 Requirement

UniFi Protect requires IPv6 to be enabled on the host system. It doesn't need to be routed or used, just enabled.

**Verify IPv6 is enabled:**
```bash
cat /proc/sys/net/ipv6/conf/all/disable_ipv6
```
Should return `0` (enabled).

**To enable IPv6:**
```bash
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
```

Make persistent by adding to `/etc/sysctl.conf`:
```
net.ipv6.conf.all.disable_ipv6=0
```

## Initial Setup

### First-Time Configuration

1. **Disconnect from internet** - During initial setup, disconnect the host from the internet to prevent auto-updates

2. **Start the addon** - Start the addon from the Home Assistant interface

3. **Access web interface** - Navigate to `https://your-ha-ip:443`

4. **Complete setup** - Follow the offline setup wizard

5. **Disable auto-updates** - In console settings, disable auto-updates for both the console and applications

6. **Reconnect internet** - After setup is complete and auto-updates are disabled

### Why Disable Auto-Updates?

UniFi's auto-update mechanism is designed for official UniFi hardware and may break the containerized setup. Always update by rebuilding the Docker image with newer versions.

## Camera Management

### Adding Cameras

1. Navigate to the UniFi Protect web interface
2. Go to **Devices**
3. Click **Adopt** for discovered cameras
4. Or manually add cameras via IP address

### ONVIF Camera Support

UniFi Protect 5.0+ supports third-party cameras via ONVIF:

1. Ensure cameras support ONVIF protocol
2. Add via **Devices** → **Add Device** → **ONVIF Camera**
3. Provide camera IP, username, and password

### RTSP Streams

Access RTSP streams directly:

1. Go to camera settings → **Advanced**
2. Copy RTSP URL
3. Remove `?enableSrtp` from the end
4. Change port to 7447: `rtsp://your-ha-ip:7447/camera-id`

## Troubleshooting

### Addon Won't Start

**Systemd errors:**
```
Failed to create /init.scope control group: Read-only file system
```

**Solution:** Boot host with kernel parameter `systemd.unified_cgroup_hierarchy=0`

**For Home Assistant OS:** This is typically already configured correctly.

### No Logs Output

If `docker compose logs` shows no output, it's likely a systemd initialization issue. Check host system logs:

```bash
journalctl -u docker
```

### Cameras Won't Adopt

**Possible causes:**
1. Insufficient storage capacity (minimum 100GB required)
2. Network connectivity issues
3. UniFi Protect version too old for camera model
4. Ports blocked by firewall

**Solutions:**
1. Verify storage disk configuration and capacity
2. Check network connectivity between host and cameras
3. Update to latest Protect version
4. Review firewall rules for required ports

### Remote Access Not Working

**Requirements for remote access:**
- Host networking enabled
- Primary interface named `enp0s2` (see Network Configuration)
- Access to `https://static.ui.com` for MAC fingerprints
- UniFi account signed in

**Note:** Remote access does not work with Docker on macOS.

### Storage Disk Issues

**Error messages about storage:**

1. Verify device path is correct:
   ```bash
   lsblk
   ```

2. Check device permissions:
   ```bash
   ls -l /dev/sda
   ```

3. Enable debug logging:
   ```yaml
   debug_storage: true
   ```

4. Check logs at `/var/log/storage_disk_debug.log`

### Performance Issues

**If experiencing lag or crashes:**

1. **Check RAM usage** - Minimum 4GB required, 8GB recommended
2. **Verify storage performance** - Use SSD instead of SD card if possible
3. **Reduce camera count** - Start with fewer cameras on limited hardware
4. **Check CPU usage** - Consider hardware upgrade if consistently high
5. **Disable other addons** - Reduce resource contention

### Database Issues

**If UniFi Protect fails to start due to database errors:**

1. Check logs: `journalctl -u postgresql-14`
2. Verify database integrity
3. Restore from backup if necessary

**Database location:** `/data/unifi-protect/postgres`

## Logs and Monitoring

### Accessing Logs

**Via Home Assistant:**
1. Go to addon page
2. Click **Log** tab

**Within container:**
```bash
journalctl -f
```

**UniFi Protect specific:**
- UniFi Protect logs: `/srv/unifi-protect/logs`
- UniFi Core logs: `/data/unifi-core/logs`
- Storage debug logs: `/var/log/storage_disk_debug.log` (if enabled)

### Log Locations

| Component | Log Path |
|-----------|----------|
| System | `journalctl` |
| UniFi Protect | `/srv/unifi-protect/logs` |
| UniFi Core | `/data/unifi-core/logs` |
| Storage Debug | `/var/log/storage_disk_debug.log` |
| PostgreSQL | `/var/log/postgresql/` |

## Updates

### Updating the Addon

1. **Backup your data** - Always backup before updating
2. **Check for updates** - Home Assistant will notify when updates are available
3. **Review changelog** - Check CHANGELOG.md for breaking changes
4. **Install update** - Click **Update** in the addon interface
5. **Restart addon** - Addon will restart automatically

**Important:** Never downgrade UniFi Protect versions. Database migrations are one-way only.

### Camera Firmware Updates

When UniFi Protect updates, camera firmware may also update automatically. This is normal behavior.

**Note:** Downgrading camera firmware is difficult or impossible once updated.

## Integration with Home Assistant

### Future Integration Possibilities

The addon currently provides UniFi Protect functionality but does not directly integrate with Home Assistant entities. Future enhancements may include:

- Camera entities in Home Assistant
- Motion sensor binary sensors
- Recording status sensors
- Person detection sensors
- Doorbell button events

For now, use RTSP streams to integrate cameras with Home Assistant's generic camera platform.

### Using RTSP Streams in Home Assistant

Add cameras to Home Assistant configuration:

```yaml
camera:
  - platform: generic
    name: Front Door Camera
    stream_source: rtsp://your-ha-ip:7447/camera-id
    still_image_url: https://your-ha-ip:443/proxy/protect/api/cameras/camera-id/snapshot
```

## Migration from Standalone Docker

If you're currently running the standalone Docker version:

### Migration Steps

1. **Backup existing data:**
   ```bash
   docker compose down
   cp -r ./storage /backup/storage-backup
   ```

2. **Install the addon** but don't start it yet

3. **Copy data to addon storage:**
   ```bash
   # Copy to Home Assistant media directory
   cp -r /backup/storage-backup/* /usr/share/hassio/media/unifi-protect/
   ```

4. **Configure addon** with same settings as docker-compose.override.yml

5. **Start addon**

6. **Verify** all cameras and recordings are accessible

### Reverting to Standalone

To switch back to standalone Docker:

1. Stop the addon
2. Copy data from addon storage back to standalone location
3. Start standalone Docker container with `docker compose up -d`

## Security Considerations

### Privileged Mode

This addon requires privileged mode to run systemd and access hardware devices. This is necessary for the container to function but does reduce isolation.

**Security implications:**
- Container has elevated host access
- Required for systemd as PID 1
- Required for block device access

### AppArmor

AppArmor is disabled for this addon due to systemd requirements. Ensure your Home Assistant installation is properly secured with:
- Strong passwords
- Network isolation
- Regular updates
- Firewall rules

### Network Exposure

The addon uses host networking and exposes multiple ports. Ensure:
- UniFi Protect interface uses strong passwords
- HTTPS is enabled (default)
- Unnecessary ports are firewalled
- Remote access is properly secured

## Advanced Configuration

### Custom Device Emulation

The `device_type` option controls hardware emulation:

- **UNVR**: Standard 4-bay recorder
- **UNVR_PRO**: 8-bay recorder with additional features
- **ENVR**: Enterprise recorder

Different device types may have different network interface requirements.

### Debug Logging

Enable debug logging for troubleshooting:

```yaml
debug: true
```

This enables all debug options and provides verbose logging for:
- Storage operations
- UniFi Core operations
- System operations

### Storage Disk Script

The addon uses a custom `storage_disk.sh` script to manage storage operations. This script:
- Emulates UNVR storage hardware
- Manages disk mounting
- Handles storage detection

Enable debug logging to see storage script operations:

```yaml
debug_storage: true
```

## Performance Tuning

### Recommended Hardware

**Minimum Configuration:**
- Raspberry Pi 4 (4GB RAM)
- 32GB SD card (OS)
- 500GB USB SSD (storage)

**Recommended Configuration:**
- Raspberry Pi 4 or 5 (8GB RAM)
- 64GB SD card (OS)
- 1TB+ NVMe SSD via USB 3.0 (storage)

**Optimal Configuration:**
- Mini PC with ARM64 processor
- 16GB+ RAM
- NVMe SSD storage
- Gigabit+ network

### Camera Limits

**Expected camera counts by hardware:**
- Raspberry Pi 4 (4GB): 2-4 cameras
- Raspberry Pi 4 (8GB): 4-8 cameras
- Mini PC (16GB): 8-16+ cameras

Limits depend on:
- Camera resolution
- Frame rate
- Recording quality
- Motion detection load

### Storage Performance

**For best performance:**
1. Use SSD instead of SD card or HDD
2. Use USB 3.0 or faster interface
3. Ensure adequate free space
4. Regular maintenance (trim, etc.)

## FAQ

### Q: Can I run this on x86/amd64 hardware?

**A:** No, this addon is specifically for ARM64 architecture only. The UniFi Protect firmware is compiled for ARM64.

### Q: Why does it need privileged mode?

**A:** Privileged mode is required to:
- Run systemd as PID 1
- Access block devices for storage
- Emulate UNVR hardware

### Q: Can I use multiple storage disks?

**A:** Currently only single disk is supported via the `storage_disk` parameter.

### Q: Does this work with UniFi cameras only?

**A:** UniFi Protect 5.0+ supports ONVIF third-party cameras in addition to UniFi cameras.

### Q: Can I access recordings from Home Assistant?

**A:** Not directly through entities yet. Use RTSP streams or the UniFi Protect web interface at `https://your-ha-ip:443`.

### Q: What happens if I run out of storage?

**A:** UniFi Protect will automatically delete oldest recordings to make room for new ones based on retention settings.

### Q: Can I run this alongside the official UniFi Protect integration?

**A:** The official integration connects to existing UniFi Protect hardware. This addon runs UniFi Protect itself. They serve different purposes.

### Q: Is remote access secure?

**A:** Remote access through UniFi Cloud uses Ubiquiti's secure infrastructure. Ensure you use strong passwords and enable 2FA on your UniFi account.

## Support and Resources

### Getting Help

- **Main Project**: [GitHub Repository](https://github.com/dciancu/unifi-protect-unvr-docker-arm64)
- **Issues**: [GitHub Issues](https://github.com/dciancu/unifi-protect-unvr-docker-arm64/issues)
- **Discussions**: [GitHub Discussions](https://github.com/dciancu/unifi-protect-unvr-docker-arm64/discussions)

### Additional Resources

- [UniFi Protect Documentation](https://help.ui.com/hc/en-us/categories/360003683753-UniFi-Protect)
- [ONVIF Camera Support](https://help.ui.com/hc/en-us/articles/26301104828439-Third-Party-Cameras-in-UniFi-Protect)
- [Home Assistant Documentation](https://www.home-assistant.io/docs/)

### Contributing

Contributions to improve the addon are welcome! Please submit pull requests to the main repository.

## Disclaimer

This is an experimental project. I do not take responsibility for anything regarding the use or misuse of the contents of this repository.

By using this project you accept all risk associated with it and releasing all parties from any liability associated with this software.

This project is not associated with UniFi and/or Ubiquiti in any way. We do not distribute any third party software and only use packages that are freely available on the internet.

# Changelog

All notable changes to the HAProxy & Marzban Automation Suite will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-06

### 🎉 Major Release - Enhanced Edition

This is a complete rewrite of the automation suite with professional-grade features.

### Added

#### Core Features
- **Backup & Rollback System**: Automatic timestamped backups before any configuration changes
- **Restore Functionality**: One-command rollback to any previous state
- **CLI Support**: Full command-line interface for automation and scripting
- **Diagnostics Tool**: Built-in system health checker (`--diagnostics`)
- **Uninstaller**: Clean removal with backup preservation (`--uninstall`)
- **Input Validation**: Domain and port validation before configuration
- **Enhanced Logging**: Timestamped, color-coded logs with severity levels

#### HAProxy Module
- Port 443 availability check before installation
- Configuration validation before applying changes
- Service status verification after installation
- Automatic backup of existing configs
- Configuration summary display after installation
- HAProxy version detection

#### Warp Module
- **Safe Marzban Integration**: Surgical JSON injection using `jq`
- **JSON Validation**: Ensure configs are valid before saving
- **Retry Mechanism**: Robust `wgcf` download with automatic retries (3 attempts)
- **Duplicate Detection**: Check for existing Warp configs before adding
- **Automatic Integration**: Optional one-command Marzban config integration
- **Backup Support**: Backup Marzban config before modifications

#### Utilities
- `backup_file()`: Backup any file with timestamp
- `restore_backup()`: Restore from specific or latest backup
- `list_backups()`: List all available backups
- `validate_domain()`: Domain format validation with regex
- `validate_port()`: Port range validation (1-65535)
- `check_port_free()`: Check if port is available
- `check_dependencies()`: Verify required packages
- `confirm_action()`: Interactive confirmation prompts
- `log_success()`: Success message logging

### Changed

#### Common Module (`src/common.sh`)
- Added global variables for backup directory and project paths
- Enhanced logging functions with timestamps
- Improved error handling with return codes instead of exits
- Added version display in banner (v2.0.0)
- Better OS detection with logging

#### Main Installer (`install.sh`)
- Complete rewrite with CLI argument parsing
- Added `--help` flag with usage examples
- Added `--haproxy`, `--warp`, `--both` flags
- Added `--diagnostics`, `--rollback`, `--list-backups` flags
- Added `--uninstall` flag
- Enhanced interactive menu with new options
- Export `BASE_DIR` for module sourcing

#### HAProxy Module (`src/haproxy.sh`)
- Input validation loops for all domains and ports
- Backup existing config before overwriting
- Config validation using `haproxy -c`
- Service status check after restart
- Detailed configuration summary
- Better error handling with early returns

#### Warp Module (`src/warp.sh`)
- Complete rewrite with `jq` for JSON manipulation
- Safe Marzban config integration
- Retry logic for `wgcf` download
- JSON validation before saving
- Backup support for Wireguard and Marzban configs
- Enhanced user prompts and confirmations
- Better error messages and logging

### Fixed
- Package installation now checks return codes
- Service failures are properly detected and reported
- JSON configs are validated before being applied
- Port conflicts are detected before installation
- Backup restoration handles missing files gracefully

### Security
- Config files are validated before overwriting
- Backups are created before any destructive operations
- JSON is parsed safely using `jq` instead of string manipulation
- File permissions are properly set (600 for sensitive configs)

### Documentation
- Complete README rewrite with screenshots
- Added CHANGELOG.md
- Added AGENT_LOGS.md for AI development tracking
- Enhanced inline code comments
- Added usage examples for all CLI flags
- Bilingual documentation (English & Persian)

### Technical Improvements
- Modular architecture with clear separation of concerns
- Proper error propagation with return codes
- Consistent logging format across all modules
- Better variable scoping and quoting
- POSIX-compliant shell scripting practices
- Comprehensive input validation

---

## [1.0.0] - 2024-XX-XX

### Initial Release

- Basic HAProxy SNI routing setup
- Cloudflare Warp installation
- Interactive menu interface
- Support for VLESS, VMess, Trojan, Hysteria2, Reality
- Warp+ license support
- Basic documentation

---

[2.0.0]: https://github.com/tawanamohammadi/haprox-marz/releases/tag/v2.0.0
[1.0.0]: https://github.com/tawanamohammadi/haprox-marz/releases/tag/v1.0.0

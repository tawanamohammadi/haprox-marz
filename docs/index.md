# 📘 Marzban & HAProxy Automation Tools

Welcome to the documentation for the **HAProxy & Marzban Automation Suite**. This repository provides a unified automated installer to streamline the deployment of HAProxy SNI routing and Cloudflare Warp integration for Marzban panels.

## 🚀 Available Tools

All tools are accessible via the main `install.sh` script.

### 1. [HAProxy SNI Router](haproxy.md)
Automated setup for HAProxy to route multiple protocols (VLESS, VMess, Trojan, Hysteria, Reality) over a single port (443) using SNI.

- **Module:** `src/haproxy.sh`
- **Features:** SSL Passthrough, Interactive Setup, Multi-backend support.

### 2. [Marzban Cloudflare Warp](warp.md)
Hardened script to install and configure Cloudflare Warp (WireGuard) for Marzban, optimizing outbound traffic routing.

- **Module:** `src/warp.sh`
- **Features:** Hardened security, Warp+ support, Xray & Kernel modes.

## 📥 Quick Start

Clone the repository and run the installer:

```bash
git clone https://github.com/tawanamohammadi/haprox-marz.git
cd haprox-marz
chmod +x install.sh
sudo ./install.sh
```

## 🔍 SEO Keywords
- HAProxy SNI Router
- Marzban Warp Installer
- Cloudflare Warp WireGuard for Xray
- VLESS VMess Trojan Hysteria Reality over 443
- Ubuntu Debian TLS routing

## 🛠 Support

For issues and feature requests, please open an issue in the GitHub repository.

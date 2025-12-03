# 🌩️ Marzban Cloudflare Warp (Hardened)

This script (`setup.sh`) automates the installation and configuration of Cloudflare Warp for Marzban, providing a secure and optimized outbound connection.

## ✨ Features

- **Security Hardened:** Runs with `set -euo pipefail`, verifies SHA256 checksums, and sets strict file permissions (`600`).
- **Warp+ Support:** Easily integrate your Warp+ license key.
- **Dual Modes:**
  1.  **Xray Core Method:** Generates an outbound JSON for Xray (recommended for newer versions).
  2.  **Wireguard Kernel Method:** Sets up a system WireGuard interface.
- **Custom Routing:** Supports custom domains and full traffic routing.
- **Safe Handling:** Sanitizes inputs to prevent injection attacks.

## 📦 Installation

```bash
cd scripts
chmod +x setup.sh
sudo ./setup.sh
```

## 🛠 Configuration Steps

1.  **Choose Method:**
    *   **Option 1 (Xray Core):** Best for performance and integration with Marzban. Creates `warp_xray_outbound.json`.
    *   **Option 2 (Kernel):** Creates a system network interface (`wg-quick@warp`).

2.  **Warp+ License:** Enter your key if you have one.

3.  **Routing:**
    *   Select whether to route ALL traffic or specific domains (e.g., Google, Netflix, OpenAI).

## 📂 Generated Files

The script saves configuration files in `/opt/marzban-warp/` and copies relevant ones to `/root/` for easy access:

- **Xray Outbound:** `/root/warp_xray_outbound.json`
- **Freedom Outbound:** `/root/warp_freedom_outbound.json`
- **Routing Rules:** `/root/warp_routing_rule.json`
- **WireGuard Config:** `/etc/wireguard/warp.conf` (if Kernel method chosen)

## 🔗 Integration with Marzban

After running the script:

1.  Open your Marzban Panel -> **Core Settings**.
2.  **Add Outbound:** Copy content from `warp_xray_outbound.json` (or `freedom`) into the `outbounds` section.
3.  **Add Routing Rules:** Copy content from `warp_routing_rule.json` into the `routing` -> `rules` section.
4.  **Restart Core.**

## ⚠️ Important Notes

- **Architecture:** Automatically detects `amd64` or `arm64`.
- **Dependencies:** Installs `wireguard`, `curl`, `jq`, etc.
- **Security:** All sensitive files (private keys) are readable only by root.

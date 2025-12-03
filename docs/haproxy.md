# 🛡️ HAProxy SNI Router (tawanaHAproxy)

**tawanaHAproxy.sh** is an interactive Bash script that installs and configures **HAProxy** to handle multiple secure VPN protocols over **a single port (443)** using **SNI-based TCP routing**.

## 🌟 Features

- **Auto-Installation:** Automatically checks and installs HAProxy.
- **Interactive Setup:** Prompts for domains and ports for each service.
- **SNI Routing:** Routes traffic based on the Server Name Indication (SNI) hostname.
- **Multi-Protocol:** Supports VLESS, VMess, Trojan, Hysteria2, Reality, and Panel traffic.
- **Zero Dependencies:** Minimal requirements, uses standard system tools.

## 📋 Prerequisites

- **OS:** Ubuntu 20.04+, Debian 11/12.
- **Root Access:** Must be run as root.
- **Port 443:** Must be free on the server.
- **DNS Records:** A Records pointing to your server IP for all subdomains.

## 🚀 Installation

```bash
cd scripts
chmod +x tawanaHAproxy.sh
./tawanaHAproxy.sh
```

## ⚙️ Configuration Logic

The script routes traffic based on the SNI (domain name) sent by the client:

| Domain Type | Default Port | Backend Name | Protocol |
| :--- | :--- | :--- | :--- |
| **Panel** | `8000` | `be_panel` | HTTP/TCP |
| **VLESS+WS** | `1001` | `be_ws` | WebSocket+TLS |
| **VMess+TCP** | `1002` | `be_tcp` | TCP+TLS |
| **Trojan/XHTTP** | `1003` | `be_xhttp` | TCP+TLS |
| **Hysteria2** | `1004` | `be_hysteria` | UDP (via TCP workaround if applicable) / QUIC |
| **Reality** | `1005` | `be_reality` | TCP+XTLS |

*Note: Ports can be customized during installation.*

## 📝 Example Usage

1. Run the script.
2. Enter your panel domain (e.g., `panel.example.com`).
3. Enter domains for other protocols (or skip/reuse if using advanced configs).
4. Confirm ports.
5. The script generates `/etc/haproxy/haproxy.cfg` and restarts the service.

## 🔧 Troubleshooting

- **Service failed to start:** Check if port 443 is already in use (`netstat -tulnp | grep 443`).
- **Connection issues:** Ensure your domains resolve correctly and your backend services (Xray/Marzban) are listening on the correct local ports (e.g., 1001, 1002...).

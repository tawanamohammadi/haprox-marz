# 🚀 HAProxy & Marzban Automation Suite

**Automated, secure, and efficient tools for deploying HAProxy and Cloudflare Warp with Marzban.**

This repository provides a unified installer to streamline your VPN infrastructure setup.

## 📂 Repository Structure

```
.
├── docs/               # 📚 Detailed Documentation
├── src/                # 🔧 Source Code (Modular)
│   ├── common.sh       # Shared Utilities
│   ├── haproxy.sh      # HAProxy Logic
│   └── warp.sh         # Warp Logic
├── install.sh          # 🚀 Main Installer Script
└── README.md           # This file
```

## ⚡ Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/haprox-marz.git
   cd haprox-marz
   ```

2. **Run the installer:**
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

3. **Select an option:**
   - **1) HAProxy Router:** Set up SNI routing for multiple protocols over port 443.
   - **2) Cloudflare Warp:** Configure secure outbound routing (Warp+ supported).
   - **3) Full Setup:** Install both tools sequentially.

## 📖 Documentation

Full documentation is available in the `docs/` directory.

- [Documentation Home](docs/index.md)
- [HAProxy Guide](docs/haproxy.md)
- [Warp Guide](docs/warp.md)

## 📜 License

Released under the MIT License.

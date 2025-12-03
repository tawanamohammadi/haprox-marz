# 🚀 HAProxy & Marzban Automation Suite

- [فارسی](#فارسی)
- [English](#english)

SEO keywords: HAProxy SNI Multiplexer, Marzban Warp Installer, Cloudflare Warp WireGuard, VLESS VMess Trojan Hysteria Reality, Marzban Panel Setup, TLS Router 443, Ubuntu Debian

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
   git clone https://github.com/tawanamohammadi/haprox-marz.git
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

---

## فارسی

### معرفی
این پروژه یک نصب‌کننده یکپارچه برای راه‌اندازی سریع و امن **HAProxy (مسیر‌دهی بر اساس SNI روی پورت ۴۴۳)** و **Cloudflare Warp (WireGuard)** در کنار پنل **مرزبان (Marzban)** است.

### قابلیت‌ها
- نصب خودکار HAProxy و تولید کانفیگ تمیز برای مسیر‌دهی دامنه‌ها (SNI)
- تولید خروجی‌های موردنیاز مرزبان برای استفاده از Warp (Xray یا Kernel)
- پشتیبانی از پروتکل‌ها: VLESS WS، VMess TCP، Trojan/XHTTP، Hysteria2، Reality، پنل

### پیش‌نیازها
- Ubuntu 20.04+ یا Debian 11/12 و دسترسی `sudo`
- خالی بودن پورت `443` روی سرور
- تنظیم رکوردهای DNS برای دامنه‌های SNI (panel/ws/tcp/...)

### نصب سریع
```bash
git clone https://github.com/tawanamohammadi/haprox-marz.git
cd haprox-marz
chmod +x install.sh
sudo ./install.sh
```

در منو:
- گزینه ۱: نصب و پیکربندی HAProxy (مسیر‌دهی مبتنی بر SNI)
- گزینه ۲: نصب Warp و ساخت خروجی‌های لازم برای مرزبان
- گزینه ۳: هر دو مورد به ترتیب

### نکات کلیدی
- HAProxy فقط عبور TLS را انجام می‌دهد؛ گواهی‌ها روی سرویس‌های پشت (Xray/Panel/...) باید معتبر باشند.
- برای Warp، فایل‌های خروجی در مسیر `/root/warp_xray_outbound.json` و `~/warp_routing_rule.json` ساخته می‌شوند.

---

## English

### Overview
This repository provides a unified installer to deploy **HAProxy (SNI-based TLS routing on port 443)** and **Cloudflare Warp (WireGuard)** alongside the **Marzban panel**.

### Features
- Auto-install HAProxy and generate clean SNI-based routing config
- Generate Marzban-friendly Warp outbounds (Xray or Kernel method)
- Supports: VLESS WS, VMess TCP, Trojan/XHTTP, Hysteria2, Reality, Panel

### Prerequisites
- Ubuntu 20.04+ or Debian 11/12 with `sudo`
- Port `443` must be free
- DNS records for SNI subdomains configured

### Quick Install
```bash
git clone https://github.com/tawanamohammadi/haprox-marz.git
cd haprox-marz
chmod +x install.sh
sudo ./install.sh
```

Menu options:
- 1) Install and configure HAProxy (SNI routing)
- 2) Install Warp and generate Marzban outbounds
- 3) Install both sequentially

### Notes
- HAProxy does TLS passthrough; certificates live on backend services (Xray/Panel/etc.)
- Warp outputs: `/root/warp_xray_outbound.json` and `/root/warp_routing_rule.json`

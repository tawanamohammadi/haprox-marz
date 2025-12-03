# 🛡️ tawanaHAproxy.sh

> Automated, elegant SNI-based TLS router setup using HAProxy  
> Built for power users, VPN admins, and stealthy deployment lovers 🧙‍♂️

![tawanaproxy](https://img.shields.io/badge/HAProxy-Auto--Router-blue?style=flat-square&logo=haproxy)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange?style=flat-square&logo=ubuntu)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## 📜 License

Released under the MIT License. See the [LICENSE](LICENSE) file for details.
## 🚀 What is this?

**`tawanaHAproxy.sh`** is an interactive Bash script that installs and configures **HAProxy** to handle multiple secure VPN protocols over **a single port (443)** using **SNI-based TCP routing**.

Designed for modern VPN gateways running:
- VLESS (WebSocket)
- VMess (TCP)
- Trojan
- Hysteria2 (QUIC)
- Reality
- Admin panel (e.g. Marzban)

---

## ⚙️ Features

- ✅ Auto-installs HAProxy
- ✅ Fully interactive input (asks for domains & ports)
- ✅ Produces a clean `/etc/haproxy/haproxy.cfg`
- ✅ Restarts and enables the service
- ✅ Supports 6 separate backends over one secure entry point
- ✅ No unnecessary dependencies

---

## 🔧 Supported Architecture

| Domain Purpose     | Protocol Type | Backend Name     | Default Port |
|-------------------|----------------|------------------|---------------|
| Panel / Dashboard | TCP            | `be_panel`       | `8000`        |
| VLESS + WS        | TCP (WS+TLS)   | `be_ws`          | `1001`        |
| VMess + TCP       | TCP + TLS      | `be_tcp`         | `1002`        |
| Trojan / XHTTP    | TCP + TLS      | `be_xhttp`       | `1003`        |
| Hysteria 2        | QUIC (UDP)     | `be_hysteria`    | `1004`        |
| Reality           | TCP + XTLS     | `be_reality`     | `1005`        |

> 🧠 You can customize each backend port/domain during script execution.

---

## 📋 Prerequisites

- سرور لینوکسی با Ubuntu 20.04+ یا Debian 11/12 و دسترسی sudo/root
- آزاد بودن پورت 443 و عدم استفاده همزمان توسط سرویس دیگر
- تنظیم رکوردهای DNS برای دامنه‌های SNI (panel/ws/tcp/xhttp/dl/notify)
- داشتن گواهی‌های معتبر روی سرویس‌های بک‌اند (Xray، Hysteria2، Trojan، Reality)
- در ویندوز، اجرای اسکریپت‌ها از طریق WSL یا روی یک سرور لینوکسی ریموت

## 📦 Installation & Usage

### 1. Clone the repo

```bash
git clone https://github.com/TAwR00T/haprox-marz.git
cd haprox-marz
```

### 2. Run the script

```bash
chmod +x tawanaHAproxy.sh
./tawanaHAproxy.sh
```

You will be prompted to enter:

- Domain for each service (SNI match)
- Local port of each service
- That’s it — fully configured!

---

## 🔐 Sample TLS Routing Setup

```
INTERNET → port 443 (HAProxy TLS passthrough)
        ├── nesh.domain.ir      → 127.0.0.1:8000 (Panel)
        ├── ws.domain.ir        → 127.0.0.1:1001 (VLESS+WS)
        ├── tcp.domain.ir       → 127.0.0.1:1002 (VMess)
        ├── xhttp.domain.ir     → 127.0.0.1:1003 (Trojan)
        ├── dl.domain.ir        → 127.0.0.1:1004 (Hysteria2)
        └── notify.domain.ir    → 127.0.0.1:1005 (Reality)
```

---

## ✅ Tested On

- ✅ Ubuntu 20.04 / 22.04 / 24.04
- ✅ Debian 11 / 12
- ✅ HAProxy 2.2+ (comes from apt)
- ✅ Works with Cloudflare (orange cloud) and full SNI

---

## ⚠️ Notes

- TLS termination is handled by **each service (e.g. Xray, Hysteria, etc.)**, not HAProxy.
- Make sure valid certificates are in place on backend services.
- Port 443 **must be free** when starting HAProxy.

---

## 👤 Author

**[@TAwR00T](https://github.com/TAwR00T)**  
Made with ❤️ by the TAWANA Network  
"Secure your stack. Hide in plain sight."

---

---

## 🧪 Quick Start

```bash
chmod +x tawanaHAproxy.sh
sudo ./tawanaHAproxy.sh
```

ورودی‌های موردنیاز:
- دامنه‌های SNI برای هر سرویس
- پورت داخلی هر سرویس (در صورت عدم تغییر از مقادیر پیش‌فرض استفاده می‌شود)

پس از اجرا:
- فایل کانفیگ در مسیر `/etc/haproxy/haproxy.cfg` ایجاد می‌شود
- سرویس HAProxy فعال و راه‌اندازی می‌شود

## 🧰 Troubleshooting
- اگر پورت 443 اشغال است، سرویس‌های متداخل را متوقف کنید
- اطمینان از Resolve شدن دامنه‌ها به IP درست و فعال بودن SNI در کلادفلر (Orange Cloud)
- لاگ‌ها را بررسی کنید:
```bash
sudo journalctl -u haproxy -f
```

## 🧱 Security Notes
- کلیدها و گواهی‌ها را روی بک‌اندها امن نگه‌دارید و در لاگ‌ها چاپ نکنید
- تنها دامنه‌های قابل اعتماد را در SNI تنظیم کنید
- دسترسی ssh و sudo را محدود کنید

---

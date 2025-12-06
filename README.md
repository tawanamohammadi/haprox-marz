# 🚀 HAProxy & Marzban Automation Suite

**Enhanced Edition v2.0.0** - Professional automation tool for HAProxy SNI routing and Cloudflare Warp integration with Marzban panel.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](https://github.com/tawanamohammadi/haprox-marz)
[![Bash](https://img.shields.io/badge/bash-5.0+-orange.svg)](https://www.gnu.org/software/bash/)

---

## 📖 Language / زبان

- [English](#english)
- [فارسی](#فارسی)

---

## English

### 🎯 What's New in v2.0.0

- ✅ **Rollback System**: Automatic backups with one-command restore
- ✅ **Safe Marzban Integration**: Surgical JSON injection without breaking configs
- ✅ **CLI Support**: Full command-line interface for automation
- ✅ **Diagnostics Tool**: Built-in system health checker
- ✅ **Input Validation**: Domain and port validation before configuration
- ✅ **Enhanced Logging**: Timestamped logs with color-coded output
- ✅ **Uninstaller**: Clean removal with backup preservation

### 📸 Preview

![Terminal Preview](C:/Users/lol/.gemini/antigravity/brain/9f792fe4-3d77-44c6-97d9-5f27799c658d/terminal_preview_1765035405871.png)

### ⚡ Quick Install

```bash
git clone https://github.com/tawanamohammadi/haprox-marz.git
cd haprox-marz
chmod +x install.sh
sudo ./install.sh
```

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/tawanamohammadi/haprox-marz/main/install.sh | sudo bash
```

### 🎮 Usage

#### Interactive Mode
```bash
sudo ./install.sh
```

#### CLI Mode
```bash
# Install HAProxy only
sudo ./install.sh --haproxy

# Install Warp only
sudo ./install.sh --warp

# Install both
sudo ./install.sh --both

# Run diagnostics
sudo ./install.sh --diagnostics

# Rollback to latest backup
sudo ./install.sh --rollback

# List available backups
sudo ./install.sh --list-backups

# Uninstall everything
sudo ./install.sh --uninstall

# Show help
sudo ./install.sh --help
```

### 🌟 Features

#### HAProxy SNI Router
- **TLS Passthrough**: Route multiple domains over port 443
- **Protocol Support**: VLESS WS, VMess TCP, Trojan/XHTTP, Hysteria2, Reality, Panel
- **Auto-Configuration**: Generate clean HAProxy configs automatically
- **Validation**: Config validation before applying changes
- **Port Checking**: Ensure port 443 is available before installation

#### Cloudflare Warp Integration
- **Dual Methods**: Xray core or Kernel WireGuard
- **Warp+ Support**: Optional license key integration
- **Safe Integration**: Automatic Marzban config injection with validation
- **Retry Mechanism**: Robust download with automatic retries
- **JSON Validation**: Ensure configs are valid before saving

#### Backup & Rollback
- **Automatic Backups**: All configs backed up before changes
- **Timestamped Storage**: Easy identification of backup versions
- **One-Command Restore**: Quick rollback to any previous state
- **Selective Restore**: Restore specific components

### 📋 Installation Flow

![Installation Flow](C:/Users/lol/.gemini/antigravity/brain/9f792fe4-3d77-44c6-97d9-5f27799c658d/installation_flow_1765035468051.png)

### 🔧 Prerequisites

- **OS**: Ubuntu 20.04+ or Debian 11/12
- **Access**: Root or sudo privileges
- **Port**: 443 must be free
- **DNS**: Records configured for SNI subdomains
- **Dependencies**: curl, jq, wireguard-tools (auto-installed)

### 📂 Repository Structure

```
.
├── docs/               # 📚 Documentation Website
├── src/                # 🔧 Source Code (Modular)
│   ├── common.sh       # Shared utilities, backup, validation
│   ├── haproxy.sh      # HAProxy installation logic
│   ├── warp.sh         # Warp installation with Marzban integration
│   ├── diagnostics.sh  # System health checker
│   └── uninstall.sh    # Clean uninstaller
├── install.sh          # 🚀 Main installer with CLI support
├── AGENT_LOGS.md       # 🤖 AI development logs
└── README.md           # This file
```

### 🔍 Diagnostics

Check system status anytime:
```bash
sudo ./install.sh --diagnostics
```

The diagnostics tool checks:
- ✅ System information
- ✅ Port availability
- ✅ Service status (HAProxy, Wireguard, Marzban)
- ✅ Configuration file existence
- ✅ Warp connectivity
- ✅ Backup status
- ✅ Dependencies

### 🛠️ Configuration

#### HAProxy
- **Config**: `/etc/haproxy/haproxy.cfg`
- **Service**: `systemctl status haproxy`
- **Logs**: `journalctl -u haproxy -f`

#### Warp
- **Xray Outbound**: `/root/warp_xray_outbound.json`
- **Routing Rule**: `/root/warp_routing_rule.json`
- **Kernel Config**: `/etc/wireguard/warp.conf`
- **Service**: `systemctl status wg-quick@warp`

#### Backups
- **Location**: `.backup/<timestamp>/`
- **Latest**: `.backup/latest`

### 🆘 Troubleshooting

**Port 443 in use:**
```bash
# Check what's using the port
sudo ss -tulnp | grep :443

# Or use diagnostics
sudo ./install.sh --diagnostics
```

**Restore from backup:**
```bash
# List backups
sudo ./install.sh --list-backups

# Restore latest
sudo ./install.sh --rollback

# Restore specific backup
sudo ./install.sh --rollback 20250106_120000
```

**Warp not working:**
```bash
# Run diagnostics
sudo ./install.sh --diagnostics

# Check Marzban logs
docker logs marzban -f
```

### 📜 License

Released under the [MIT License](LICENSE).

### 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

### 📚 Documentation

Full documentation is available at: [https://tawanamohammadi.github.io/haprox-marz](https://tawanamohammadi.github.io/haprox-marz)

---

## فارسی

### 🎯 ویژگی‌های جدید نسخه 2.0.0

- ✅ **سیستم بازگردانی**: پشتیبان‌گیری خودکار با بازگردانی تک‌دستوری
- ✅ **ادغام ایمن مرزبان**: تزریق دقیق JSON بدون خراب کردن تنظیمات
- ✅ **پشتیبانی CLI**: رابط خط فرمان کامل برای اتوماسیون
- ✅ **ابزار عیب‌یابی**: بررسی‌کننده سلامت سیستم داخلی
- ✅ **اعتبارسنجی ورودی**: اعتبارسنجی دامنه و پورت قبل از پیکربندی
- ✅ **لاگ پیشرفته**: لاگ‌های زمان‌دار با خروجی رنگی
- ✅ **حذف‌کننده**: حذف تمیز با حفظ پشتیبان

### 📸 پیش‌نمایش

![پیش‌نمایش ترمینال](C:/Users/lol/.gemini/antigravity/brain/9f792fe4-3d77-44c6-97d9-5f27799c658d/terminal_preview_1765035405871.png)

### ⚡ نصب سریع

```bash
git clone https://github.com/tawanamohammadi/haprox-marz.git
cd haprox-marz
chmod +x install.sh
sudo ./install.sh
```

**نصب تک‌خطی:**
```bash
curl -fsSL https://raw.githubusercontent.com/tawanamohammadi/haprox-marz/main/install.sh | sudo bash
```

### 🎮 استفاده

#### حالت تعاملی
```bash
sudo ./install.sh
```

#### حالت خط فرمان
```bash
# نصب فقط HAProxy
sudo ./install.sh --haproxy

# نصب فقط Warp
sudo ./install.sh --warp

# نصب هر دو
sudo ./install.sh --both

# اجرای عیب‌یابی
sudo ./install.sh --diagnostics

# بازگردانی به آخرین نسخه پشتیبان
sudo ./install.sh --rollback

# لیست نسخه‌های پشتیبان
sudo ./install.sh --list-backups

# حذف کامل
sudo ./install.sh --uninstall

# نمایش راهنما
sudo ./install.sh --help
```

### 🌟 قابلیت‌ها

#### مسیریاب SNI با HAProxy
- **عبور TLS**: مسیریابی چندین دامنه روی پورت 443
- **پشتیبانی پروتکل**: VLESS WS، VMess TCP، Trojan/XHTTP، Hysteria2، Reality، Panel
- **پیکربندی خودکار**: تولید خودکار تنظیمات تمیز HAProxy
- **اعتبارسنجی**: اعتبارسنجی تنظیمات قبل از اعمال تغییرات
- **بررسی پورت**: اطمینان از در دسترس بودن پورت 443 قبل از نصب

#### ادغام Cloudflare Warp
- **دو روش**: هسته Xray یا کرنل WireGuard
- **پشتیبانی Warp+**: ادغام اختیاری کلید لایسنس
- **ادغام ایمن**: تزریق خودکار تنظیمات مرزبان با اعتبارسنجی
- **مکانیسم تلاش مجدد**: دانلود قوی با تلاش‌های خودکار
- **اعتبارسنجی JSON**: اطمینان از معتبر بودن تنظیمات قبل از ذخیره

#### پشتیبان‌گیری و بازگردانی
- **پشتیبان‌گیری خودکار**: تمام تنظیمات قبل از تغییرات پشتیبان می‌شوند
- **ذخیره‌سازی زمان‌دار**: شناسایی آسان نسخه‌های پشتیبان
- **بازگردانی تک‌دستوری**: بازگشت سریع به هر حالت قبلی
- **بازگردانی انتخابی**: بازگردانی اجزای خاص

### 📋 جریان نصب

![جریان نصب](C:/Users/lol/.gemini/antigravity/brain/9f792fe4-3d77-44c6-97d9-5f27799c658d/installation_flow_1765035468051.png)

### 🔧 پیش‌نیازها

- **سیستم‌عامل**: Ubuntu 20.04+ یا Debian 11/12
- **دسترسی**: دسترسی root یا sudo
- **پورت**: پورت 443 باید آزاد باشد
- **DNS**: رکوردها برای زیردامنه‌های SNI پیکربندی شده باشند
- **وابستگی‌ها**: curl، jq، wireguard-tools (نصب خودکار)

### 🔍 عیب‌یابی

بررسی وضعیت سیستم در هر زمان:
```bash
sudo ./install.sh --diagnostics
```

ابزار عیب‌یابی موارد زیر را بررسی می‌کند:
- ✅ اطلاعات سیستم
- ✅ در دسترس بودن پورت‌ها
- ✅ وضعیت سرویس‌ها (HAProxy، Wireguard، Marzban)
- ✅ وجود فایل‌های پیکربندی
- ✅ اتصال Warp
- ✅ وضعیت پشتیبان
- ✅ وابستگی‌ها

### 🛠️ پیکربندی

#### HAProxy
- **تنظیمات**: `/etc/haproxy/haproxy.cfg`
- **سرویس**: `systemctl status haproxy`
- **لاگ‌ها**: `journalctl -u haproxy -f`

#### Warp
- **خروجی Xray**: `/root/warp_xray_outbound.json`
- **قانون مسیریابی**: `/root/warp_routing_rule.json`
- **تنظیمات کرنل**: `/etc/wireguard/warp.conf`
- **سرویس**: `systemctl status wg-quick@warp`

#### پشتیبان‌ها
- **مکان**: `.backup/<timestamp>/`
- **آخرین**: `.backup/latest`

### 🆘 رفع مشکلات

**پورت 443 در حال استفاده:**
```bash
# بررسی چه چیزی از پورت استفاده می‌کند
sudo ss -tulnp | grep :443

# یا از عیب‌یابی استفاده کنید
sudo ./install.sh --diagnostics
```

**بازگردانی از پشتیبان:**
```bash
# لیست پشتیبان‌ها
sudo ./install.sh --list-backups

# بازگردانی آخرین
sudo ./install.sh --rollback

# بازگردانی پشتیبان خاص
sudo ./install.sh --rollback 20250106_120000
```

**Warp کار نمی‌کند:**
```bash
# اجرای عیب‌یابی
sudo ./install.sh --diagnostics

# بررسی لاگ‌های مرزبان
docker logs marzban -f
```

### 📜 مجوز

تحت [مجوز MIT](LICENSE) منتشر شده است.

### 📚 مستندات

مستندات کامل در: [https://tawanamohammadi.github.io/haprox-marz](https://tawanamohammadi.github.io/haprox-marz)

---

**SEO Keywords**: HAProxy SNI Multiplexer, Marzban Warp Installer, Cloudflare Warp WireGuard, VLESS VMess Trojan Hysteria Reality, Marzban Panel Setup, TLS Router 443, Ubuntu Debian, Rollback System, Safe Config Integration, CLI Automation Tool

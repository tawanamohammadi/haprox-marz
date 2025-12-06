# 📸 راهنمای کپی اسکرین‌شات‌ها

## مرحله 1: ایجاد پوشه تصاویر

در ترمینال پروژه، این دستور را اجرا کنید:

```bash
mkdir -p docs/assets/images
```

## مرحله 2: کپی اسکرین‌شات‌ها

اسکرین‌شات‌ها در این مسیر هستند:
```
C:\Users\lol\.gemini\antigravity\brain\9f792fe4-3d77-44c6-97d9-5f27799c658d\
```

فایل‌ها:
- `terminal_preview_1765035405871.png`
- `installation_flow_1765035468051.png`

### با PowerShell:

```powershell
# کپی اسکرین‌شات اول
Copy-Item "C:\Users\lol\.gemini\antigravity\brain\9f792fe4-3d77-44c6-97d9-5f27799c658d\terminal_preview_1765035405871.png" -Destination "docs\assets\images\terminal_preview.png"

# کپی اسکرین‌شات دوم
Copy-Item "C:\Users\lol\.gemini\antigravity\brain\9f792fe4-3d77-44c6-97d9-5f27799c658d\installation_flow_1765035468051.png" -Destination "docs\assets\images\installation_flow.png"
```

### یا به صورت دستی:

1. پوشه `docs/assets/images` را در پروژه بسازید
2. فایل `terminal_preview_1765035405871.png` را کپی کنید و با نام `terminal_preview.png` در پوشه بالا بگذارید
3. فایل `installation_flow_1765035468051.png` را کپی کنید و با نام `installation_flow.png` در پوشه بالا بگذارید

## مرحله 3: تایید

بررسی کنید که فایل‌ها در مسیر درست هستند:

```bash
ls -la docs/assets/images/
```

باید این دو فایل را ببینید:
- `terminal_preview.png`
- `installation_flow.png`

## ✅ تمام!

حالا README و وبسایت به درستی اسکرین‌شات‌ها را نمایش می‌دهند.

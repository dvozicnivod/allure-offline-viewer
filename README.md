# Allure Offline Viewer

📦 Self-contained, GUI+CLI viewer for Allure reports — **no Python required**!

## ✅ Features

- One-click viewer for `.zip` or folder-based Allure reports
- Works offline in air-gapped environments
- Dual interface: GUI (file dialog) or CLI (`.zip` or folder path)
- Lightweight (~5MB single `.exe`)
- No installation, no admin rights needed

## 🚀 How to Use

1. Download the latest version from [`/bin`](./bin)
2. Double-click the executable
3. Select:
   - A combined `allure-report` folder **or**
   - A `.zip` archive containing the report

## 🔧 Build Instructions (for developers)

```bash
# Install PyInstaller (only needed once)
python -m pip install pyinstaller

# Build the executable
pyinstaller --onefile --name allure_viewer --add-data "temp;temp" --hidden-import tkinter allure_offline_viewer.py

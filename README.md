# 🛡 Linux File Integrity Monitoring System (FIM)

> A Bash-based Host Intrusion Detection System (HIDS) that monitors file integrity, permissions, and ownership changes on Linux systems.

---

## 📌 Overview

The **Linux File Integrity Monitoring (FIM)** system detects unauthorized modifications to critical system files.

It verifies:

- File content (SHA256 hash)
- File permissions (chmod changes)
- File ownership (chown changes)
- Missing files

The tool supports both **manual execution** and **automated monitoring via cron**.

---

## 🚀 Key Features

| Feature | Description |
|----------|-------------|
| 🔐 Hash Verification | Detects file content modification using SHA256 |
| 🔄 Permission Monitoring | Detects chmod changes |
| 👤 Ownership Monitoring | Detects chown or group changes |
| ⚠ Missing File Detection | Identifies deleted monitored files |
| 📊 Report Generation | Timestamped integrity reports |
| 🎨 CLI Alerts | Color-coded alert system |
| ⏰ Automation | Cron-based scheduled execution |

---

## 🧠 Security Concepts Implemented

- Cryptographic Hashing (SHA256)
- Linux Permission Model
- File Ownership Control
- Metadata Integrity Validation
- Host-Based Intrusion Detection (HIDS)
- Scheduled Security Monitoring

---

## 🛠 Technologies Used

- Bash Scripting
- sha256sum
- stat
- awk
- cron

---

## 📂 Project Structure
```
Linux-File-Integrity-Monitor/
│
├── fim.sh
├── .gitignore
├── README.md
└── screenshot.png
```

# Steam ExFAT Bind

Run Steam games directly from an **exFAT external SSD** on Linux with Proton support.  
This script solves the issue where Steam can’t create `compatdata` (Proton prefixes) on exFAT because it doesn’t support Linux symlinks or permissions.

Instead, it redirects all Proton prefixes into your Linux home (Btrfs/Ext4/etc.) and bind-mounts them back into the SSD’s `SteamLibrary` so Steam sees everything as native.

---

## 🚀 Features
- Works with **exFAT SSDs** shared between Linux, Windows, and macOS  
- Keeps Proton prefixes (`compatdata`) safe in your Linux home  
- Seamless Steam integration — games run as if installed natively  
- Avoids “Device or resource busy” errors  
- Plug-and-play style: run one command after mounting your SSD  

---

## 📦 Requirements
- Linux (tested on Arch / CachyOS, should work on most distros)  
- `rsync` and `udisks2` (usually preinstalled)  
- Steam installed with Proton enabled  

---

## ⚙️ Setup

### 1. Clone repo
```bash
git clone https://github.com/<your-username>/steam-exfat-bind.git
cd steam-exfat-bind
````

### 2. Make script executable

```bash
chmod +x steambind.sh
```

### 3. Optional: Add alias (Fish shell example)

Edit `~/.config/fish/config.fish`:

```fish
alias steambind="~/steam-exfat-bind/steambind.sh"
```

Reload config:

```fish
source ~/.config/fish/config.fish
```

---

## 🖥️ Usage

1. Mount your SSD (exFAT won’t auto-mount on some distros):

```bash
udisksctl mount -b /dev/sdX1
```

*(replace `/dev/sdX1` with your SSD partition — e.g. `/dev/sdb1`)*

2. Run the bind script:

```bash
steambind
```

---

## 🔍 How It Works

* Proton prefixes (`compatdata`) normally live inside each Steam library.
* exFAT cannot handle symlinks/permissions, so Steam fails.
* This script:

  1. Creates a safe prefix folder inside Linux home (`~/SteamPrefixes/compatdata`)
  2. Moves/merges any existing compatdata into it
  3. Empty-cleans SSD’s `compatdata` folder
  4. Bind-mounts the home folder back into the SSD so Steam is happy

---

## 🛠️ Troubleshooting

* **Game won’t launch after reboot** → Just re-run `steambind` after mounting the SSD.
* **Steam still crashes** → Ensure no leftover `compatdata` on SSD, clear it and retry.
* **SSD not auto-detected** → Use `lsblk` to check the partition and mount manually with `udisksctl`.

---

## 📜 License

MIT License. Do whatever you want with it.
Credit appreciated but not required ✌️

---

## 💡 Future Improvements

* Auto-detect SSD partition by label (no `/dev/sdX` guesswork)
* Systemd unit for fully automated bind after mount
* Support for multiple external Steam libraries

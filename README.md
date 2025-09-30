# Steam exFAT Bind Mount Helper

> **Play Steam games from exFAT external drives on Linux**

A simple script that enables Steam's Proton compatibility layer to work properly with games installed on exFAT-formatted external drives.

## 🎮 The Problem

Steam's Proton (Wine compatibility layer) requires:
- Symbolic links
- Proper UNIX permissions
- Extended attributes

**exFAT doesn't support any of these**, causing games to fail with errors like:
- "Failed to create Wine prefix"
- "Unable to initialize Steam API"
- Games refusing to launch

## ✨ The Solution

This script creates a **bind mount** that redirects the `compatdata` directory (Wine prefixes) from your exFAT drive to your internal Linux drive, while keeping game files on the external drive.

### Benefits:
- ✅ Keep large game files on external drive
- ✅ Proton prefixes work properly on internal drive
- ✅ No need to reformat to ext4/NTFS
- ✅ Portable - works across distributions
- ✅ Safe - no data loss, easily reversible

## 📋 Requirements

- Linux (any distribution)
- Steam installed
- `sudo` privileges
- `rsync` installed (usually pre-installed)

## 🚀 Quick Start

### 1. Download the script

```bash
git clone https://github.com/PSYRJT/steam-exfat-bind.git
cd steam-exfat-bind
chmod +x steam-exfat-bind.sh
```

### 2. Run the script

```bash
./steam-exfat-bind.sh
```

The script will:
- Auto-detect your external Steam library
- Create a prefix storage location
- Set up the bind mount
- Merge any existing compatdata

### 3. Launch Steam

That's it! Launch Steam and your games should now work properly.

## 📖 Usage

1. Edit the .sh file and replace yourusername and yourSSD with own names.
2. Mount SSD
3. Run script
4. Must be re-run every restart and every remount


## 🔧 How It Works

```
Before:
External Drive (exFAT)
└── SteamLibrary/
    └── steamapps/
        ├── common/         (game files - stays here)
        └── compatdata/     (Wine prefixes - doesn't work on exFAT)

After:
External Drive (exFAT)
└── SteamLibrary/
    └── steamapps/
        ├── common/         (game files)
        └── compatdata/  ──→ [bind mounted to internal drive]

Internal Drive (ext4)
└── ~/SteamPrefixes/
    └── compatdata/         (actual Wine prefixes stored here)
```

## 🐛 Troubleshooting

### "SSD not mounted" error
Make sure your external drive is actually mounted before running the script.

### Permission issues
The script requires `sudo` to create bind mounts. Make sure you have sudo privileges.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Ideas for improvements:
- [ ] GUI version
- [ ] Automatic detection of when drive is connected
- [ ] Integration with GNOME/KDE
- [ ] Support for multiple external drives simultaneously
- [ ] Automatic backup of compatdata

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Credits

- Created by psyrjt (and ChatGPT)
- Inspired by the Linux gaming community

## ⚠️ Disclaimer

This script modifies system mounts. While safe when used correctly, always backup important data. The authors are not responsible for any data loss.

---

**Found this helpful?** Give it a ⭐ on GitHub!

**Having issues?** Open an issue and we'll help you out.

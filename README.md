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
git clone https://github.com/yourusername/steam-exfat-bind.git
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

### Basic usage (auto-detect)
```bash
./steam-exfat-bind.sh
```

### Specify drive manually
```bash
./steam-exfat-bind.sh -d /run/media/username/GameDrive
```

### Custom prefix location
```bash
./steam-exfat-bind.sh -d /mnt/games -p ~/MyPrefixes
```

### Unmount all binds
```bash
./steam-exfat-bind.sh -u
```

### Show help
```bash
./steam-exfat-bind.sh -h
```

## ⚙️ Automatic Setup (systemd)

To automatically mount on boot/login:

### 1. Create systemd service file

Create `/etc/systemd/system/steam-exfat-bind@.service`:

```ini
[Unit]
Description=Steam exFAT Bind Mount for %i
After=local-fs.target

[Service]
Type=oneshot
User=%i
ExecStart=/path/to/steam-exfat-bind.sh
RemainAfterExit=yes
ExecStop=/path/to/steam-exfat-bind.sh -u

[Install]
WantedBy=multi-user.target
```

### 2. Enable the service

```bash
sudo systemctl enable steam-exfat-bind@$USER.service
sudo systemctl start steam-exfat-bind@$USER.service
```

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

### Games still won't launch
1. Try removing the game's compatdata folder: `rm -rf ~/SteamPrefixes/compatdata/<AppID>`
2. Verify Steam in the game
3. Relaunch the game

### Permission issues
The script requires `sudo` to create bind mounts. Make sure you have sudo privileges.

### Unmount before ejecting
Always run `./steam-exfat-bind.sh -u` before ejecting your external drive.

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

- Created by psyrjt
- Inspired by the Linux gaming community
- Thanks to everyone who reported issues and suggested improvements

## ⚠️ Disclaimer

This script modifies system mounts. While safe when used correctly, always backup important data. The authors are not responsible for any data loss.

---

**Found this helpful?** Give it a ⭐ on GitHub!

**Having issues?** Open an issue and we'll help you out.

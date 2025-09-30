#!/bin/bash
set -e

USER="yourusername"
SSD_LABEL="yourSSD"
SSD_MOUNTPOINT="/run/media/$USER/$SSD_LABEL"
SSD_STEAMAPPS="$SSD_MOUNTPOINT/SteamLibrary/steamapps"
PREFIX_HOME="/home/$USER/SteamPrefixes/compatdata"

echo "[Steam Bind] Starting..."

# Check if SSD is mounted
if [ ! -d "$SSD_MOUNTPOINT" ]; then
    echo "[Steam Bind] SSD not mounted! Please mount it first."
    exit 1
fi

# Ensure directories exist
mkdir -p "$PREFIX_HOME"
mkdir -p "$SSD_STEAMAPPS/compatdata"

# Merge existing compatdata from SSD to home safely
if [ -d "$SSD_STEAMAPPS/compatdata" ] && [ ! "$(mountpoint -q "$SSD_STEAMAPPS/compatdata")" ]; then
    echo "[Steam Bind] Merging existing compatdata..."
    rsync -a --ignore-existing "$SSD_STEAMAPPS/compatdata/" "$PREFIX_HOME/"
    # Empty SSD folder so bind works
    rm -rf "$SSD_STEAMAPPS/compatdata"/*
fi

# Bind mount
if ! mountpoint -q "$SSD_STEAMAPPS/compatdata"; then
    echo "[Steam Bind] Applying bind mount..."
    sudo mount --bind "$PREFIX_HOME" "$SSD_STEAMAPPS/compatdata"
fi

echo "[Steam Bind] Done! Steam can launch now."

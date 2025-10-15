#!/bin/bash
set -euo pipefail

SCRIPT_NAME="Steam Bind"

# Defaults (can be overridden via env or args)
CURRENT_USER="${USER:-$(whoami)}"
HOME_DIR="${HOME:-/home/$CURRENT_USER}"
PREFIX_HOME_DEFAULT="$HOME_DIR/SteamPrefixes/compatdata"
STEAMAPPS_ARG=""
DRY_RUN="false"
DO_UNBIND="false"

log() {
    echo "[$SCRIPT_NAME] $*"
}

err() {
    echo "[$SCRIPT_NAME][ERROR] $*" >&2
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || { err "Required command not found: $1"; exit 1; }
}

usage() {
    cat <<EOF
$SCRIPT_NAME - Run Steam Proton from exFAT by bind-mounting compatdata.

Usage: ${0##*/} [options]

Options:
  --library PATH     Path to Steam library's steamapps directory (e.g. /run/media/
                     USER/SSD/SteamLibrary/steamapps). If omitted, auto-detects.
  --prefix PATH      Where to keep compatdata in Linux home (default: $PREFIX_HOME_DEFAULT)
  --unbind           Unmount the bind at steamapps/compatdata (no data loss)
  -n, --dry-run      Show actions without making changes
  -h, --help         Show this help

Env:
  STEAM_LIBRARY      Alternative to --library
  STEAM_PREFIX_HOME  Alternative to --prefix
EOF
}

PREFIX_HOME="${STEAM_PREFIX_HOME:-$PREFIX_HOME_DEFAULT}"

# Parse args
while [ $# -gt 0 ]; do
    case "$1" in
        --library)
            shift; STEAMAPPS_ARG="${1:-}" ;;
        --prefix)
            shift; PREFIX_HOME="${1:-}" ;;
        --unbind)
            DO_UNBIND="true" ;;
        -n|--dry-run)
            DRY_RUN="true" ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            err "Unknown argument: $1"; usage; exit 1 ;;
    esac
    shift || true
done

# Dependencies
need_cmd rsync
need_cmd mount
need_cmd sudo
need_cmd findmnt

# Resolve library steamapps directory
detect_steamapps() {
    # Priority: explicit arg -> env -> auto-detect
    local candidate
    if [ -n "$STEAMAPPS_ARG" ]; then
        echo "$STEAMAPPS_ARG"
        return 0
    fi
    if [ -n "${STEAM_LIBRARY:-}" ]; then
        echo "$STEAM_LIBRARY"
        return 0
    fi

    # Common locations: /run/media/$USER/*/SteamLibrary/steamapps, /mnt/*/SteamLibrary/steamapps
    for path in \
        "/run/media/$CURRENT_USER"/*/SteamLibrary/steamapps \
        "/mnt"/*/SteamLibrary/steamapps \
        "$HOME_DIR/.steam/steam/steamapps" \
        "$HOME_DIR/.local/share/Steam/steamapps"
    do
        if [ -d "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

STEAMAPPS_DIR="$(detect_steamapps || true)"
if [ -z "$STEAMAPPS_DIR" ]; then
    err "Could not find Steam library 'steamapps'. Use --library PATH."
    exit 1
fi

COMPATDATA_MOUNTPOINT="$STEAMAPPS_DIR/compatdata"

log "Using steamapps: $STEAMAPPS_DIR"
log "Compatdata target: $COMPATDATA_MOUNTPOINT"
log "Prefix home: $PREFIX_HOME"

# Ensure directories
if [ "$DRY_RUN" = "false" ]; then
    mkdir -p "$PREFIX_HOME"
    mkdir -p "$COMPATDATA_MOUNTPOINT"
fi

# Unbind flow
if [ "$DO_UNBIND" = "true" ]; then
    if findmnt -rno TARGET -- "$COMPATDATA_MOUNTPOINT" >/dev/null 2>&1; then
        log "Unbinding $COMPATDATA_MOUNTPOINT"
        if [ "$DRY_RUN" = "false" ]; then
            sudo umount "$COMPATDATA_MOUNTPOINT"
        fi
        log "Unbound successfully."
    else
        log "No bind mount present at $COMPATDATA_MOUNTPOINT"
    fi
    exit 0
fi

# Merge existing compatdata if not already a mountpoint
if ! findmnt -rno TARGET -- "$COMPATDATA_MOUNTPOINT" >/dev/null 2>&1; then
    if [ -d "$COMPATDATA_MOUNTPOINT" ]; then
        log "Merging existing compatdata from library into prefix home (one-way, keep existing in home)."
        if [ "$DRY_RUN" = "false" ]; then
            rsync -a --ignore-existing "$COMPATDATA_MOUNTPOINT/" "$PREFIX_HOME/"
            # Empty only top-level entries to avoid deleting the directory itself
            rm -rf "$COMPATDATA_MOUNTPOINT"/* || true
        fi
    fi
fi

# Bind mount if not already bound
if ! findmnt -rno TARGET -- "$COMPATDATA_MOUNTPOINT" >/dev/null 2>&1; then
    log "Applying bind mount..."
    if [ "$DRY_RUN" = "false" ]; then
        sudo mount --bind "$PREFIX_HOME" "$COMPATDATA_MOUNTPOINT"
    fi
else
    log "Already bound: $COMPATDATA_MOUNTPOINT"
fi

log "Done! Steam can launch now."

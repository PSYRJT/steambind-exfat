#!/bin/bash
set -euo pipefail

# Simple Zenity GUI wrapper for steambind.sh

need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd zenity; then
  echo "zenity is required for the GUI. Install it (e.g., sudo pacman -S zenity)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_SCRIPT="$SCRIPT_DIR/steambind.sh"

if [ ! -x "$CORE_SCRIPT" ]; then
  zenity --error --title="Steam Bind" --text="Core script not found or not executable:\n$CORE_SCRIPT"
  exit 1
fi

action=$(zenity --list --radiolist \
  --title="Steam Bind" \
  --text="Choose an action" \
  --column "Select" --column "Action" --column "Description" \
  TRUE "Bind/Run" "Bind compatdata and enable Proton from exFAT" \
  FALSE "Unbind" "Remove bind mount only (no data loss)" \
  FALSE "Dry Run" "Preview actions without changes" \
  --height=300 --width=600) || exit 0

# Optionally let user pick a Steam library path
ask_library=$(zenity --question --title="Steam Bind" --text="Specify a Steam library path? (Otherwise auto-detect)" --ok-label="Yes" --cancel-label="No"; echo $?)
library_arg=()
if [ "$ask_library" = "0" ]; then
  path=$(zenity --file-selection --directory --title="Select steamapps directory" 2>/dev/null || true)
  if [ -n "${path:-}" ]; then
    library_arg=(--library "$path")
  fi
fi

case "$action" in
  "Bind/Run")
    out=$("$CORE_SCRIPT" "${library_arg[@]}" 2>&1 | sed 's/&/\&/g') || true
    zenity --info --title="Steam Bind" --text="<tt>${out}</tt>" --width=700 --height=400 --no-wrap
    ;;
  "Unbind")
    out=$("$CORE_SCRIPT" --unbind "${library_arg[@]}" 2>&1 | sed 's/&/\&/g') || true
    zenity --info --title="Steam Bind" --text="<tt>${out}</tt>" --width=700 --height=400 --no-wrap
    ;;
  "Dry Run")
    out=$("$CORE_SCRIPT" --dry-run "${library_arg[@]}" 2>&1 | sed 's/&/\&/g') || true
    zenity --info --title="Steam Bind" --text="<tt>${out}</tt>" --width=700 --height=400 --no-wrap
    ;;
  *)
    ;;
esac



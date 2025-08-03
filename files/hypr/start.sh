#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

log() { echo "[start.sh] $1" >&2; }

# Start background services
swww-daemon --format xrgb || log "swww already running"
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Wait for Hyprland client from PID
get_wid_by_pid() {
  local pid=$1
  local wid=""
  for _ in {1..100}; do
    wid=$(hyprctl clients -j | jq -r --arg pid "$pid" '.[] | select(.pid == ($pid | tonumber)) | .address')
    [[ -n "$wid" ]] && echo "$wid" && return 0
    sleep 0.1
  done
  log "Window for pid $pid not found"
  return 1
}

# ───────────────────────────────
# 1. Top-left Ghostty
ghostty &
pid1=$!
wid1=$(get_wid_by_pid "$pid1")
sleep 0.5
hyprctl dispatch movewindowpixel exact 6 48,address:$wid1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid1

# 2. Bottom-left Ghostty
ghostty &
pid2=$!
wid2=$(get_wid_by_pid "$pid2")
sleep 0.5
hyprctl dispatch movewindowpixel exact 6 1107,address:$wid2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid2

# 3. Zen browser (center)
flatpak run app.zen_browser.zen &
pid3=$!
wid3=$(get_wid_by_pid "$pid3")
sleep 1
hyprctl dispatch movewindowpixel exact 1566 48,address:$wid3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$wid3

# 4. Discord (right)
discord &
pid4=$!
wid4=$(get_wid_by_pid "$pid4")
sleep 1
hyprctl dispatch movewindowpixel exact 3596 48,address:$wid4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$wid4

log "Layout complete."


#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

echo "[start.sh] Starting wallpaper and background apps..."

swww-daemon --format xrgb &>/dev/null &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &

nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

set -e

get_addr_by_pid() {
  local pid=$1
  local addr
  for _ in {1..50}; do
    addr=$(hyprctl clients -j | jq -r --arg pid "$pid" '.[] | select(.pid == ($pid | tonumber)) | .address')
    [[ -n "$addr" && "$addr" != "null" ]] && break
    sleep 0.1
  done
  echo "$addr"
}

# ──────── 1. Top-left Ghostty ────────
ghostty & pid1=$!
addr1=$(get_addr_by_pid "$pid1")
hyprctl dispatch movewindowpixel exact 6 48,address:$addr1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr1

# ──────── 2. Bottom-left Ghostty ────────
ghostty & pid2=$!
addr2=$(get_addr_by_pid "$pid2")
hyprctl dispatch movewindowpixel exact 6 1107,address:$addr2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr2

# ──────── 3. Zen Browser (center, full height) ────────
flatpak run app.zen_browser.zen & pid3=$!
addr3=$(get_addr_by_pid "$pid3")
hyprctl dispatch movewindowpixel exact 1566 48,address:$addr3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$addr3

# ──────── 4. Discord (right, full height) ────────
discord & pid4=$!
addr4=""
for i in {1..100}; do
  sleep 0.2
  addr4=$(hyprctl clients -j | jq -r --arg pid "$pid4" '.[] | select(.pid == ($pid | tonumber)) | .address')
  [ -n "$addr4" ] && break
done

sleep 1.2
hyprctl dispatch movewindowpixel exact 3596 48,address:$addr4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$addr4


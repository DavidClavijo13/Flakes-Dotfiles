#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
set -e

# ─────────── Background daemons & wallpaper ───────────
swww-daemon --format xrgb &>/dev/null &
sleep 0.3
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# ─────────── Helper: wait for a window by PID ───────────
get_addr_by_pid() {
  local pid=$1 addr
  for _ in {1..80}; do
    addr=$(hyprctl clients -j \
      | jq -r --arg pid "$pid" '.[] | select(.pid == ($pid|tonumber)) | .address')
    [[ -n "$addr" && "$addr" != "null" ]] && break
    sleep 0.1
  done
  echo "$addr"
}

# ─────────── 1) Ghostty (top-left) ───────────
ghostty & pid1=$!
addr1=$(get_addr_by_pid "$pid1")
hyprctl dispatch togglefloating address:$addr1
hyprctl dispatch movewindowpixel exact 6 48,address:$addr1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr1

# ─────────── 2) Ghostty (bottom-left) ───────────
ghostty & pid2=$!
addr2=$(get_addr_by_pid "$pid2")
hyprctl dispatch togglefloating address:$addr2
hyprctl dispatch movewindowpixel exact 6 1107,address:$addr2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr2

# ─────────── 3) Zen Browser (center) ───────────
flatpak run app.zen_browser.zen & pid3=$!
addr3=$(get_addr_by_pid "$pid3")
hyprctl dispatch togglefloating address:$addr3
hyprctl dispatch movewindowpixel exact 1566 48,address:$addr3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$addr3

# ─────────── 4) Discord (right) ───────────
discord & pid4=$!
addr4=$(get_addr_by_pid "$pid4")

# make sure it's floating _before_ moving
hyprctl dispatch togglefloating address:$addr4
# give it a moment so it doesn't snap back to tiling
sleep 0.5

hyprctl dispatch movewindowpixel exact 3596 48,address:$addr4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$addr4


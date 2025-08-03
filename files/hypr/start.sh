#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

echo "[start.sh] Starting wallpaper and background apps..."
swww-daemon --format xrgb 2>/dev/null &
sleep 0.3
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

wait_for_pid_window() {
  local pid=$1
  for i in {1..100}; do
    addr=$(hyprctl clients -j | jq -r --arg pid "$pid" '.[] | select(.pid == ($pid | tonumber)) | .address')
    [ -n "$addr" ] && echo "$addr" && return
    sleep 0.1
  done
}

# ──────── 1. Top-left Ghostty ────────
ghostty & pid1=$!
addr1=$(wait_for_pid_window "$pid1")
hyprctl dispatch movewindowpixel exact 6 48,address:$addr1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr1

# ──────── 2. Bottom-left Ghostty ────────
ghostty & pid2=$!
addr2=$(wait_for_pid_window "$pid2")
hyprctl dispatch movewindowpixel exact 6 1107,address:$addr2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr2

# ──────── 3. Center Zen Browser ────────
flatpak run app.zen_browser.zen & pid3=$!
addr3=$(wait_for_pid_window "$pid3")
hyprctl dispatch movewindowpixel exact 1566 48,address:$addr3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$addr3

# ──────── 4. Right-side Discord ────────
discord & pid4=$!
addr4=$(wait_for_pid_window "$pid4")
hyprctl dispatch movewindowpixel exact 3596 48,address:$addr4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$addr4


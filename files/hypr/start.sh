#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
set -e

# —————————————————————————————————————————————————————————
# Helper: wait for a window to appear by its PID, then return its Hyprland address
get_addr_by_pid() {
  local pid=$1
  local addr=""
  for _ in {1..50}; do
    addr=$(hyprctl clients -j \
      | jq -r --arg pid "$pid" '.[] 
          | select(.pid == ($pid|tonumber)) 
          | .address') 
    [[ -n "$addr" && "$addr" != "null" ]] && break
    sleep 0.1
  done
  echo "$addr"
}

# —————————————————————————————————————————————————————————
# 0) Background daemons & wallpaper
swww-daemon --format xrgb &>/dev/null &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# —————————————————————————————————————————————————————————
# 1) Top-Left Ghostty
ghostty & pid_top=$!
addr_top=$(get_addr_by_pid "$pid_top")
hyprctl dispatch togglefloating address:$addr_top
hyprctl dispatch movewindowpixel exact 6 48,address:$addr_top
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr_top

# —————————————————————————————————————————————————————————
# 2) Center Zen Browser (full height)
flatpak run app.zen_browser.zen & pid_zen=$!
addr_zen=$(get_addr_by_pid "$pid_zen")
hyprctl dispatch togglefloating address:$addr_zen
hyprctl dispatch movewindowpixel exact 1566 48,address:$addr_zen
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$addr_zen

# —————————————————————————————————————————————————————————
# 3) Right-Side Discord (full height)
discord & pid_discord=$!
addr_discord=""
for _ in {1..80}; do
  addr_discord=$(hyprctl clients -j \
    | jq -r --arg pid "$pid_discord" '.[] 
        | select(.pid == ($pid|tonumber) and .title|test("Discord|Friends")) 
        | .address')
  [[ -n "$addr_discord" && "$addr_discord" != "null" ]] && break
  sleep 0.15
done

hyprctl dispatch togglefloating address:$addr_discord
hyprctl dispatch movewindowpixel exact 3596 48,address:$addr_discord
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$addr_discord

# —————————————————————————————————————————————————————————
# 4) Bottom-Left Ghostty
ghostty & pid_bot=$!
addr_bot=$(get_addr_by_pid "$pid_bot")
hyprctl dispatch togglefloating address:$addr_bot
hyprctl dispatch movewindowpixel exact 6 1107,address:$addr_bot
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr_bot


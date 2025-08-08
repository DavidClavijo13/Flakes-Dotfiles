#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

target_ws=1

# --- Services ---
swww-daemon --format xrgb &>/dev/null & sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & ~/.config/hypr/toggle-waybar.sh & mako &

# --- Switch to target workspace ---
hyprctl dispatch workspace "$target_ws"

# --- Launch apps ---
ghostty &
flatpak run app.zen_browser.zen &
discord &

# --- Wait until all three classes are present ---
while true; do
  clients=$(hyprctl clients -j)
  got_ghost=$(echo "$clients" | jq -e '.[] | select(.class=="com.mitchellh.ghostty")' >/dev/null && echo 1 || echo 0)
  got_zen=$(echo "$clients" | jq -e '.[] | select(.class=="zen")' >/dev/null && echo 1 || echo 0)
  got_discord=$(echo "$clients" | jq -e '.[] | select(.class=="discord")' >/dev/null && echo 1 || echo 0)
  
  if [ "$got_ghost" -eq 1 ] && [ "$got_zen" -eq 1 ] && [ "$got_discord" -eq 1 ]; then
    break
  fi
  sleep 0.2
done

# --- Identify window addresses by class ---
ghost_id=$(echo "$clients" | jq -r '[.[]|select(.class=="com.mitchellh.ghostty")][0].address')
zen_id=$(echo "$clients" | jq -r '[.[]|select(.class=="zen")][0].address')
discord_id=$(echo "$clients" | jq -r '[.[]|select(.class=="discord")][0].address')

# --- Make sure they're tiled ---
for id in "$ghost_id" "$zen_id" "$discord_id"; do
  hyprctl dispatch setfloating disable,address:"$id"
done

# --- Place left → center → right ---
hyprctl dispatch focuswindow address:"$ghost_id"
hyprctl dispatch movewindow l
sleep 0.05
hyprctl dispatch focuswindow address:"$zen_id"
hyprctl dispatch movewindow r
sleep 0.05
hyprctl dispatch focuswindow address:"$discord_id"
hyprctl dispatch movewindow r
sleep 0.05


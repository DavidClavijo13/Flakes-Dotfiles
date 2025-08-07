#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

staging_ws=99
target_ws=1

# --- Services ---
swww-daemon --format xrgb &>/dev/null & sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & ~/.config/hypr/toggle-waybar.sh & mako &

# --- Launch apps ---
ghostty & 
ghostty & 
flatpak run app.zen_browser.zen & 
discord &
sleep 2

# --- Identify ---
clients=$(hyprctl clients -j)
mapfile -t ghost_ids < <(echo "$clients" | jq -r \
  '[.[]|select(.class=="com.mitchellh.ghostty")]|sort_by(.at[1])|.[].address')
zen_id=$(echo "$clients" | jq -r '[.[]|select(.class=="zen")]|max_by(.size[1])|.address')
discord_id=$(echo "$clients" | jq -r '[.[]|select(.class=="discord")]|max_by(.size[1])|.address')

# --- Stage & float for exact positioning ---
hyprctl dispatch workspace "$staging_ws"
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$staging_ws",address:"$id"
  hyprctl dispatch togglefloating address:"$id"
done
sleep 0.1

# --- Position exactly ---
# Ghostty top
hyprctl dispatch movewindowpixel exact 6 48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}
# Ghostty bottom
hyprctl dispatch movewindowpixel exact 6 1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}
# Zen center
hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id
# Discord right
hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id

# --- Enable pseudotile for each ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch pseudotile address:"$id"
done

# --- Unfloat so they are in tiling tree but keep sizes ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:"$id"
done

# --- Move to target workspace ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$target_ws",address:"$id"
done
hyprctl dispatch workspace "$target_ws"

# --- Debug ---
hyprctl clients -j | jq '.[] | {class, at, size, floating, pseudotiled}'


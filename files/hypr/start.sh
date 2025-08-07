#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

staging_ws=99
target_ws=1

# --- Start services ---
swww-daemon --format xrgb &>/dev/null & sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & ~/.config/hypr/toggle-waybar.sh & mako &

# --- Launch apps ---
ghostty & 
ghostty & 
flatpak run app.zen_browser.zen & 
discord &
sleep 2

# --- Identify windows ---
clients=$(hyprctl clients -j)
mapfile -t ghost_ids < <(echo "$clients" | jq -r \
  '[.[]|select(.class=="com.mitchellh.ghostty")]|sort_by(.at[1])|.[].address')
zen_id=$(echo "$clients" | jq -r '[.[]|select(.class=="zen")]|max_by(.size[1])|.address')
discord_id=$(echo "$clients" | jq -r '[.[]|select(.class=="discord")]|max_by(.size[1])|.address')

# --- Send all to staging workspace, tile ---
hyprctl dispatch workspace "$staging_ws"
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$staging_ws",address:"$id"
  hyprctl dispatch setfloating disable,address:"$id"
done
sleep 0.1

# --- Build layout ---
# Focus Ghostty-top first
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"

# Force vertical split for root container
hyprctl dispatch layoutmsg orientationvertical

# Add Ghostty-bottom BELOW Ghostty-top
hyprctl dispatch focuswindow address:"${ghost_ids[1]}"
hyprctl dispatch movewindow d
sleep 0.05

# Focus Ghostty-top again, split right for Zen
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"
hyprctl dispatch movewindow r
hyprctl dispatch focuswindow address:"$zen_id"
sleep 0.05

# Zen → split right for Discord
hyprctl dispatch movewindow r
hyprctl dispatch focuswindow address:"$discord_id"
sleep 0.05

# --- Adjust split ratios ---
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"
hyprctl dispatch splitratio 0.31  # left column width
sleep 0.05
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"
hyprctl dispatch splitratio 0.50  # top/bottom in left stack
sleep 0.05

# --- Pseudotile & pixel sizes ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch pseudotile address:"$id"
done
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}
hyprctl dispatch movewindowpixel exact 6 48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}
hyprctl dispatch movewindowpixel exact 6 1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id
hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id
hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id

# --- Back to target workspace ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$target_ws",address:"$id"
done
hyprctl dispatch workspace "$target_ws"


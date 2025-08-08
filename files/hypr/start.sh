#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

target_ws=1

# --- Services ---
swww-daemon --format xrgb &>/dev/null & sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & ~/.config/hypr/toggle-waybar.sh & mako &

# --- Launch apps in target workspace ---
hyprctl dispatch workspace "$target_ws"
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

# --- FLOAT EVERYTHING IMMEDIATELY ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:"$id"
done

# --- Switch to master layout ---
hyprctl dispatch layout master

# --- Place windows in master order ---
# 1) Ghostty-top (already focused) → move Ghostty-bottom DOWN
hyprctl dispatch focuswindow address:"${ghost_ids[1]}"
hyprctl dispatch movewindow d
sleep 0.05

# 2) Focus Ghostty-top again → move Zen RIGHT
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"
hyprctl dispatch movewindow r
sleep 0.05

# 3) Focus Zen → move Discord RIGHT
hyprctl dispatch focuswindow address:"$zen_id"
hyprctl dispatch movewindow r
sleep 0.05


# --- Pseudotile + exact sizing ---
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

# --- UNFLOAT ALL ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:"$id"
done

# --- Switch back to dwindle ---
hyprctl dispatch layout dwindle

# --- Debug check ---
hyprctl clients -j | jq '.[] | {class, at, size, floating, pseudotiled}'


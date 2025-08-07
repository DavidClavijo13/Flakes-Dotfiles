#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# --- CONFIG ---
staging_ws=99     # temporary empty workspace
target_ws=1       # your main workspace at login

# --- SERVICES ---
swww-daemon --format xrgb &>/dev/null & sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & ~/.config/hypr/toggle-waybar.sh & mako &

# --- LAUNCH APPS ---
ghostty & 
ghostty & 
flatpak run app.zen_browser.zen & 
discord &

# Give them time to appear
sleep 2

# --- IDENTIFY WINDOWS ---
clients=$(hyprctl clients -j)
mapfile -t ghost_ids < <(echo "$clients" | jq -r \
  '[.[]|select(.class=="com.mitchellh.ghostty")]|sort_by(.at[1])|.[].address')
zen_id=$(echo "$clients" | jq -r '[.[]|select(.class=="zen")]|max_by(.size[1])|.address')
discord_id=$(echo "$clients" | jq -r '[.[]|select(.class=="discord")]|max_by(.size[1])|.address')

# --- MOVE ALL TO STAGING WORKSPACE + TILE ---
hyprctl dispatch workspace "$staging_ws"
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$staging_ws",address:"$id"
  hyprctl dispatch setfloating disable,address:"$id"
done
sleep 0.1

# --- BUILD LAYOUT ---
# 1) Focus Ghostty TOP
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"
# Ensure first split is vertical (left vs right)
hyprctl dispatch layoutmsg togglesplit
sleep 0.05

# 2) Zen to the RIGHT of Ghostty top
hyprctl dispatch focuswindow address:"$zen_id"
hyprctl dispatch movewindow r
sleep 0.05

# 3) Discord to the RIGHT of Zen
hyprctl dispatch focuswindow address:"$discord_id"
hyprctl dispatch movewindow r
sleep 0.05

# 4) Ghostty BOTTOM under Ghostty TOP (stacked left)
hyprctl dispatch focuswindow address:"${ghost_ids[1]}"
hyprctl dispatch movewindow d
sleep 0.05

# --- SET RATIOS ---
# Left/right split ratio
hyprctl dispatch splitratio 0.31
sleep 0.05
# Stack split ratio
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"
hyprctl dispatch splitratio 0.50
sleep 0.05

# --- PSEUDOTILE & EXACT SIZES ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch pseudotile address:"$id"
done

# Ghostty top
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}
hyprctl dispatch movewindowpixel exact 6 48,address:${ghost_ids[0]}
# Ghostty bottom
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}
hyprctl dispatch movewindowpixel exact 6 1107,address:${ghost_ids[1]}
# Zen center
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id
hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
# Discord right
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id
hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id

# --- MOVE BACK TO TARGET WORKSPACE ---
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$target_ws",address:"$id"
done

# --- SWITCH TO TARGET WORKSPACE ---
hyprctl dispatch workspace "$target_ws"


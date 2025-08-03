#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
set -e

# ─────────── Autostart background services ───────────
swww-daemon --format xrgb &>/dev/null &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# ─────────── Launch your four target apps ───────────
ghostty &
ghostty &
flatpak run app.zen_browser.zen &
discord &

# Give them time to map
sleep 1

# ─────────── Grab window IDs ───────────
# 1) Two Ghostty windows, sorted by Y (so the smaller Y = top)
mapfile -t ghost_ids < <(
  hyprctl clients -j \
    | jq -r '[ .[] 
        | select(.class=="com.mitchellh.ghostty") ] 
      | sort_by(.at[1]) 
      | .[].address'
)

# 2) Zen and Discord
zen_id=$(hyprctl clients -j | jq -r '.[] | select(.class=="zen") | .address')
discord_id=$(hyprctl clients -j | jq -r '.[] | select(.class=="discord") | .address')

# ─────────── Position & Size ───────────
# Top-left Ghostty
hyprctl dispatch togglefloating address:${ghost_ids[0]}
hyprctl dispatch movewindowpixel exact 6 48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}

# Bottom-left Ghostty
hyprctl dispatch togglefloating address:${ghost_ids[1]}
hyprctl dispatch movewindowpixel exact 6 1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}

# Center Zen
hyprctl dispatch togglefloating address:$zen_id
hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id

# Right Discord
hyprctl dispatch togglefloating address:$discord_id
hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id


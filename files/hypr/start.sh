#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
set -e

# ──────── 0. Autostart background services ────────
swww-daemon --format xrgb &>/dev/null &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# ──────── 1. Launch your four windows ────────
ghostty &
ghostty &
flatpak run app.zen_browser.zen &
discord &

# ──────── 2. Give them time to appear ────────
sleep 2

# ──────── 3. Grab all clients JSON once ────────
clients=$(hyprctl clients -j)

# ──────── 4. Extract window addresses ────────
# Two Ghostty, sorted by Y (top then bottom):
mapfile -t ghost_ids < <(
  echo "$clients" \
    | jq -r '[.[] | select(.class=="com.mitchellh.ghostty")] 
           | sort_by(.at[1]) 
           | .[].address'
)

# Zen (pick the tallest):
zen_id=$(echo "$clients" \
  | jq -r '[.[] | select(.class=="zen")] | max_by(.size[1]) | .address')

# Discord (pick the tallest):
discord_id=$(echo "$clients" \
  | jq -r '[.[] | select(.class=="discord")] | max_by(.size[1]) | .address')

# ──────── 5. Float & place exact pixels ────────
for id in "${ghost_ids[0]}" "${ghost_ids[1]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:$id
done

hyprctl dispatch movewindowpixel exact 6   48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}

hyprctl dispatch movewindowpixel exact 6 1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}

hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id

hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id

# ──────── 6. Unfloat in a controlled order & shove into position (tiled) ────────
# 1) Make Zen the base (center column)
hyprctl dispatch togglefloating address:$zen_id
hyprctl dispatch focuswindow address:$zen_id

# 2) Put Discord to the RIGHT of Zen
hyprctl dispatch togglefloating address:$discord_id
hyprctl dispatch focuswindow address:$discord_id
hyprctl dispatch movewindow r

# 3) Put Ghostty TOP to the LEFT of Zen
hyprctl dispatch togglefloating address:${ghost_ids[0]}
hyprctl dispatch focuswindow address:${ghost_ids[0]}
hyprctl dispatch movewindow l

# 4) Put Ghostty BOTTOM under the top Ghostty (left column stack)
hyprctl dispatch togglefloating address:${ghost_ids[1]}
hyprctl dispatch focuswindow address:${ghost_ids[1]}
hyprctl dispatch movewindow l
hyprctl dispatch movewindow d


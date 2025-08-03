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
# Two Ghostty, sorted by Y (at[1]):
mapfile -t ghost_ids < <(
  echo "$clients" \
    | jq -r '[.[] | select(.class=="com.mitchellh.ghostty")] 
           | sort_by(.at[1]) 
           | .[].address'
)

# Zen:
zen_id=$(echo "$clients" | jq -r '.[] | select(.class=="zen") | .address')

# Discord: match the one whose title ends with " - Discord"
discord_id=$(echo "$clients" \
  | jq -r '.[] 
           | select(.class=="discord" and (.title|test(" - Discord$"))) 
           | .address'
)

# ──────── 5. Float all four ────────
hyprctl dispatch togglefloating address:${ghost_ids[0]}
hyprctl dispatch togglefloating address:${ghost_ids[1]}
hyprctl dispatch togglefloating address:$zen_id
hyprctl dispatch togglefloating address:$discord_id

# ──────── 6. Move & resize in the exact spots ────────
hyprctl dispatch movewindowpixel exact 6 48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}

hyprctl dispatch movewindowpixel exact 6 1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}

hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id

hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id


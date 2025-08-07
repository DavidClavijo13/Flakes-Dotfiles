#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
set -e

# ──────── 0) Autostart background services ────────
swww-daemon --format xrgb &>/dev/null || true &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & disown || true
~/.config/hypr/toggle-waybar.sh & disown || true
mako & disown || true

# Keep dwindle from “helpfully” flipping our splits
hyprctl keyword dwindle:preserve_split true >/dev/null

# ──────── 1) Launch your four windows ────────
ghostty &
ghostty &
flatpak run app.zen_browser.zen &
discord &

# ──────── 2) Give them time to appear ────────
sleep 2

# ──────── 3) Grab all clients JSON once ────────
clients=$(hyprctl clients -j)

# ──────── 4) Extract window addresses ────────
# Two Ghostty, sorted by Y (top then bottom)
mapfile -t ghost_ids < <(
  echo "$clients" \
    | jq -r '[.[] | select(.class=="com.mitchellh.ghostty")] 
           | sort_by(.at[1]) 
           | .[].address'
)

# Tallest zen
zen_id=$(echo "$clients" \
  | jq -r '[.[] | select(.class=="zen")] | max_by(.size[1]) | .address')

# Tallest discord
discord_id=$(echo "$clients" \
  | jq -r '[.[] | select(.class=="discord")] | max_by(.size[1]) | .address')

# ──────── 5) Float & pixel-place (your working step) ────────
for id in "${ghost_ids[0]}" "${ghost_ids[1]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:$id
done

hyprctl dispatch movewindowpixel exact 6    48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}

hyprctl dispatch movewindowpixel exact 6  1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}

hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id

hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id

# ──────── 6) OPTIONAL: keep pixel sizes while tiled (pseudotile) ────────
# comment these three lines out if you don't want pseudotile
hyprctl dispatch pseudo address:$zen_id
hyprctl dispatch pseudo address:$discord_id
# (we leave the two Ghosttys true-tiled so they split evenly in the left stack)

# ──────── 7) Unfloat in a deterministic order and shape the tree ────────
# Goal: [Ghostty(top/bottom)] | [Zen (tall)] | [Discord (tall)]

# 7a) Tile ZEN first and make it the root (center column anchor)
hyprctl dispatch togglefloating address:$zen_id
hyprctl dispatch focuswindow address:$zen_id
hyprctl dispatch layoutmsg movetoroot

# 7b) Tile GHOSTTY TOP next, move it LEFT of Zen
hyprctl dispatch togglefloating address:${ghost_ids[0]}
hyprctl dispatch focuswindow address:${ghost_ids[0]}
hyprctl dispatch movewindow l

# 7c) Ensure the LEFT split is vertical (so that the Ghosttys will stack)
# (This toggles the split orientation for the current container.)
hyprctl dispatch layoutmsg togglesplit

# 7d) Tile GHOSTTY BOTTOM, move it LEFT, then DOWN (under top Ghostty)
hyprctl dispatch togglefloating address:${ghost_ids[1]}
hyprctl dispatch focuswindow address:${ghost_ids[1]}
hyprctl dispatch movewindow l
hyprctl dispatch movewindow d

# 7e) Tile DISCORD last, move it RIGHT of Zen (right column)
hyprctl dispatch togglefloating address:$discord_id
hyprctl dispatch focuswindow address:$discord_id
hyprctl dispatch movewindow r


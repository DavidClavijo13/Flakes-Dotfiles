#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
set -e

# ──────── 0. Autostart background services ────────
swww-daemon --format xrgb &>/dev/null || true &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & disown || true
~/.config/hypr/toggle-waybar.sh & disown || true
mako & disown || true

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
# Two Ghostty, sorted by Y (top then bottom)
mapfile -t ghost_ids < <(
  echo "$clients" \
    | jq -r '[.[] | select(.class=="com.mitchellh.ghostty")] 
           | sort_by(.at[1]) 
           | .[].address'
)

# Zen: pick the tallest
zen_id=$(echo "$clients" \
  | jq -r '[.[] | select(.class=="zen")] | max_by(.size[1]) | .address')

# Discord: pick the tallest
discord_id=$(echo "$clients" \
  | jq -r '[.[] | select(.class=="discord")] | max_by(.size[1]) | .address')

# ──────── 5. Float all four ────────
for id in "${ghost_ids[0]}" "${ghost_ids[1]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:$id
done

# ──────── 6. Move & resize in the exact spots (your working coords) ────────
hyprctl dispatch movewindowpixel exact 6   48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}

hyprctl dispatch movewindowpixel exact 6 1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}

hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id

hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id

# ──────── 7a. Unfloat so new windows will tile ────────
for id in "${ghost_ids[0]}" "${ghost_ids[1]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:$id
done

# ──────── 7b. Nudge the TILED layout into the right columns ────────
# Make Zen the base (center), then shove Discord to the right, Ghosttys to the left (top/bottom)
# Order matters; these are TILED moves, not pixel moves.
hyprctl dispatch focuswindow address:$zen_id
hyprctl dispatch movewindow u    # harmless if already centered; ensures Zen is in the main chain

hyprctl dispatch focuswindow address:$discord_id
hyprctl dispatch movewindow r    # right column

hyprctl dispatch focuswindow address:${ghost_ids[0]}
hyprctl dispatch movewindow l    # left column, top

hyprctl dispatch focuswindow address:${ghost_ids[1]}
hyprctl dispatch movewindow l    # into left column
hyprctl dispatch movewindow d    # stack under the top Ghostty

# Optional: preserve split orientations once we’ve placed them
hyprctl keyword dwindle:preserve_split true >/dev/null


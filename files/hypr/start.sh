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

# ──────── 1. Launch your four windows with titles ────────
ghostty --title GhosttyTop &
ghostty --title GhosttyBottom &
flatpak run app.zen_browser.zen &
discord &   # main window title will be "Friends - Discord"

# ──────── 2. Give them time to map ────────
sleep 2

# ──────── 3. Collect clients JSON ────────
clients=$(hyprctl clients -j)

# ──────── 4. Pick out the correct addresses ────────
# Ghostty Top
top_id=$(echo "$clients" \
  | jq -r '.[] 
      | select(.class=="com.mitchellh.ghostty" 
               and .title=="GhosttyTop" 
               and .size[1]==1047) 
      | .address')

# Ghostty Bottom
bottom_id=$(echo "$clients" \
  | jq -r '.[] 
      | select(.class=="com.mitchellh.ghostty" 
               and .title=="GhosttyBottom" 
               and .size[1]==1047) 
      | .address')

# Zen (center large)
zen_id=$(echo "$clients" \
  | jq -r '.[] 
      | select(.class=="zen" and .size[1]>1500) 
      | .address')

# Discord (match by title)
discord_id=$(echo "$clients" \
  | jq -r '.[] 
      | select(.class=="discord" and (.title|test("Discord"))) 
      | .address')

# ──────── 5. Float them ────────
for id in "$top_id" "$bottom_id" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:$id
done

# ──────── 6. Move & resize into exact spots ────────
hyprctl dispatch movewindowpixel exact 6    48,address:$top_id
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$top_id

hyprctl dispatch movewindowpixel exact 6   1107,address:$bottom_id
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$bottom_id

hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id

hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id

# ──────── 7. Un‐float so they tile with new windows ────────
for id in "$top_id" "$bottom_id" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:$id
done


#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# Start wallpaper
swww-daemon --format xrgb &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &

# Start background apps
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Launch apps explicitly
ghostty &
ghostty &
flatpak run app.zen_browser.zen &
discord &

# Helper function to reliably find windows by class name
get_wid_by_class() {
  local class=$1
  local wid
  until wid=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$class\" and (.at[0] + .at[1]) == 0) | .address"); do
    sleep 0.1
  done
  echo "$wid"
}

# Wait until apps launch completely
sleep 1.5

# Positioning & Resizing explicitly (with floating)

# First ghostty (top-left)
wid1=$(get_wid_by_class "com.mitchellh.ghostty")
hyprctl dispatch togglefloating address:$wid1
hyprctl dispatch movewindowpixel exact 6 48,address:$wid1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid1

# Second ghostty (bottom-left)
wid2=$(get_wid_by_class "com.mitchellh.ghostty")
hyprctl dispatch togglefloating address:$wid2
hyprctl dispatch movewindowpixel exact 6 1107,address:$wid2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid2

# Zen browser (center)
wid3=$(get_wid_by_class "zen")
hyprctl dispatch togglefloating address:$wid3
hyprctl dispatch movewindowpixel exact 1566 48,address:$wid3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$wid3

# Discord (right)
wid4=$(get_wid_by_class "discord")
hyprctl dispatch togglefloating address:$wid4
hyprctl dispatch movewindowpixel exact 3596 48,address:$wid4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$wid4


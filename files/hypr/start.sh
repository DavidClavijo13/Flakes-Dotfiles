#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# Wallpaper setup
swww-daemon --format xrgb &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &

# Background apps
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Helper function to wait until window appears
wait_for_window() {
  local class=$1
  local initial_count=$(hyprctl clients -j | jq "[.[] | select(.class == \"$class\")] | length")
  local new_count=$initial_count
  until [ "$new_count" -gt "$initial_count" ]; do
    sleep 0.1
    new_count=$(hyprctl clients -j | jq "[.[] | select(.class == \"$class\")] | length")
  done
  # Get newest window ID
  hyprctl clients -j | jq -r "[.[] | select(.class == \"$class\")] | last | .address"
}

# Launch and position the first ghostty (top-left)
ghostty &
wid1=$(wait_for_window "com.mitchellh.ghostty")
hyprctl dispatch movewindowpixel exact 6 48,address:$wid1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid1

# Launch and position second ghostty (bottom-left)
ghostty &
wid2=$(wait_for_window "com.mitchellh.ghostty")
hyprctl dispatch movewindowpixel exact 6 1107,address:$wid2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid2

# Launch and position Zen browser (center)
flatpak run app.zen_browser.zen &
wid3=$(wait_for_window "zen")
hyprctl dispatch movewindowpixel exact 1566 48,address:$wid3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$wid3

# Launch and position Discord (right)
discord &
wid4=$(wait_for_window "discord")
hyprctl dispatch movewindowpixel exact 3596 48,address:$wid4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$wid4



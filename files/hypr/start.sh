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

# Start applications explicitly (to ensure proper PIDs)
ghostty &
ghostty &
flatpak run app.zen_browser.zen &
discord &

# Helper to get Window IDs reliably by app class
get_wid_by_class() {
  local class=$1
  local wid
  until wid=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$class\" and (.at[0] + .at[1]) == 0) | .address"); do
    sleep 0.1
  done
  echo "$wid"
}

# Wait until all windows are up
sleep 1

# Arrange the first ghostty (top-left)
wid1=$(get_wid_by_class "com.mitchellh.ghostty")
hyprctl dispatch movewindowpixel exact 6 48,address:$wid1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid1

# Arrange the second ghostty (bottom-left)
wid2=$(get_wid_by_class "com.mitchellh.ghostty")
hyprctl dispatch movewindowpixel exact 6 1107,address:$wid2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid2

# Arrange Zen browser (center)
wid3=$(get_wid_by_class "zen")
hyprctl dispatch movewindowpixel exact 1566 48,address:$wid3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$wid3

# Arrange Discord (right)
wid4=$(get_wid_by_class "discord")
hyprctl dispatch movewindowpixel exact 3596 48,address:$wid4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$wid4


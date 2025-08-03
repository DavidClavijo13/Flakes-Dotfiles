#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# Wallpaper setup
swww-daemon --format xrgb &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &

# System tray apps
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Launch first terminal
ghostty &
sleep 0.3

# Move the newest ghostty to top-left
wid1=$(hyprctl clients -j | jq -r '.[] | select(.class=="com.mitchellh.ghostty") | .address' | tail -1)
hyprctl dispatch movewindowpixel exact 6 48,address:$wid1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid1

# Launch second terminal
ghostty &
sleep 0.3

# Move the newest ghostty (second one) bottom-left
wid2=$(hyprctl clients -j | jq -r '.[] | select(.class=="com.mitchellh.ghostty") | .address' | tail -1)
hyprctl dispatch movewindowpixel exact 6 1107,address:$wid2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid2

# Launch Zen browser
flatpak run app.zen_browser.zen &
sleep 0.5

# Move Zen browser
wid3=$(hyprctl clients -j | jq -r '.[] | select(.class=="zen") | .address')
hyprctl dispatch movewindowpixel exact 1566 48,address:$wid3
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$wid3

# Launch Discord
discord &
sleep 0.5

# Move Discord
wid4=$(hyprctl clients -j | jq -r '.[] | select(.class=="discord") | .address')
hyprctl dispatch movewindowpixel exact 3596 48,address:$wid4
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$wid4


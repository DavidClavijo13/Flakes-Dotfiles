#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# Wallpaper setup
swww-daemon --format xrgb &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Launch everything
ghostty &
sleep 0.5

ghostty &
sleep 0.5

flatpak run app.zen_browser.zen &
sleep 1

discord &
sleep 1

# Get window addresses in the order they actually appeared
mapfile -t ghostties < <(hyprctl clients -j | jq -r '.[] | select(.class == "com.mitchellh.ghostty") | .address')
zen=$(hyprctl clients -j | jq -r '.[] | select(.class == "zen") | .address')
discord=$(hyprctl clients -j | jq -r '.[] | select(.class == "discord") | .address')

# Reorder if needed (ghostties[0] should be top, ghostties[1] bottom)
hyprctl dispatch movewindowpixel exact 6 48,address:${ghostties[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghostties[0]}

hyprctl dispatch movewindowpixel exact 6 1107,address:${ghostties[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghostties[1]}

hyprctl dispatch movewindowpixel exact 1566 48,address:$zen
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen

hyprctl dispatch movewindowpixel exact 3596 48,address:$discord
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord


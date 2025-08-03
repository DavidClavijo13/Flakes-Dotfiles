#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

swww-daemon --format xrgb &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

ghostty --title "top-terminal" &
ghostty --title "bottom-terminal" &
flatpak run app.zen_browser.zen &
discord &


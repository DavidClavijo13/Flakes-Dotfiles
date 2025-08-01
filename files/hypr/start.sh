#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# fire up the swww daemon
swww-daemon --format xrgb &

# give it a moment to settle
sleep 0.2

# blast your wallpaper onto the screen
swww img --transition-type simple \
  "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &

nm-applet --indicator &
./toggle-waybar.sh &
mako &
flatpak run app.zen_browser.zen &
discord &
ghostty &

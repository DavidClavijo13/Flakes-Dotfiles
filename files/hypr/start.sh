#!/usr/bin/env bash
# ~/.config/hypr/start.sh
#
# Updated to ensure swww has time to initialize before setting the wallpaper.

# 1) Launch the swww daemon in the background
swww init &

# 2) Determine the runtime directory (fallback if XDG_RUNTIME_DIR isn't set)
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# 3) Wait up to 1 second for the swww socket to appear
for i in {1..10}; do
  if [ -e "${runtime_dir}/swww.sock" ]; then
    break
  fi
  sleep 0.1
done

# 4) Now set your wallpaper
swww img "${HOME}/Downloads/wp4472154-5120x2160-wallpapers.jpg" &

# 5) Launch the rest of your apps
nm-applet --indicator &
waybar &
mako &
flatpak run app.zen_browser.zen &
discord &
ghostty &


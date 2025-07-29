#!/usr/bin/env bash
# ~/.config/hypr/start.sh

LOG="$HOME/start.log"
exec &>>"$LOG"
echo "=== start.sh at $(date) ==="

# ensure your nix profile is on PATH
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
echo "PATH: $PATH"

# 1) launch the wallpaper daemon by its new name
echo "Starting swww-daemon…"
swww-daemon --format xrgb &

# give it a moment to spin up
sleep 0.5

# 2) set the wallpaper (no more ‘--duration’ args here)
echo "Setting wallpaper…"
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" \
  || echo "ERROR: swww img failed with exit $?"

# 3) the rest of your apps
echo "Launching apps…"
nm-applet --indicator &
waybar &
mako &
flatpak run app.zen_browser.zen &
discord &
ghostty &

echo "=== done at $(date) ==="


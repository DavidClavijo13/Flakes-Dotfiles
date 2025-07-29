#!/usr/bin/env bash
# ~/.config/hypr/start.sh

LOGFILE="$HOME/start.log"
exec &> >(tee -a "$LOGFILE")

echo "=== start.sh began at $(date) ==="
echo "PATH = $PATH"
# 1) Ensure your nix-profile is on PATH
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
echo "Adjusted PATH = $PATH"

# 2) Start swww and give it time
echo "Starting swww daemon…"
swww init || echo "ERROR: swww init failed!"
sleep 1

# 3) Verify the socket
echo "Runtime socket:"
ls -l "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/swww.sock" || echo "No socket!"

# 4) Call swww img via absolute path
SWWW_BIN="$(command -v swww)"
echo "swww binary at $SWWW_BIN"
"$SWWW_BIN" img "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" \
    --transition-type fade --duration 1 \
    || echo "ERROR: swww img failed!"

# 5) Launch the rest
echo "Launching apps…"
nm-applet --indicator &
waybar &
mako &
flatpak run app.zen_browser.zen &
discord &
ghostty &

echo "=== start.sh done at $(date) ==="


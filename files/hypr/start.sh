#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

log() {
  echo "[start.sh] $1" >&2
}

log "Starting wallpaper and background apps..."
swww-daemon --format xrgb &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Helper to wait for a window of a specific class + size threshold
wait_for_window() {
  local class=$1
  local min_width=${2:-800}
  local min_height=${3:-600}
  local address=""
  log "Waiting for window of class '$class' with size >= ${min_width}x${min_height}..."

  for i in {1..100}; do
    address=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$class\" and .size[0]>=$min_width and .size[1]>=$min_height) | .address" | tail -1)
    if [[ -n "$address" ]]; then
      log "Found window: $address"
      echo "$address"
      return 0
    fi
    sleep 0.1
  done

  log "Failed to find window of class $class"
  return 1
}

### STEP-BY-STEP CONTROLLED WINDOW SPAWN

### 1. Ghostty top (launch & wait)
ghostty &
wid_ghostty_top=$(wait_for_window "com.mitchellh.ghostty") || exit 1
sleep 0.5
hyprctl dispatch movewindowpixel exact 6 48,address:$wid_ghostty_top
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid_ghostty_top

### 2. Ghostty bottom (launch & wait)
ghostty &
wid_ghostty_bottom=$(wait_for_window "com.mitchellh.ghostty") || exit 1
sleep 0.5
hyprctl dispatch movewindowpixel exact 6 1107,address:$wid_ghostty_bottom
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$wid_ghostty_bottom

### 3. Zen browser
log "Launching Zen browser..."
flatpak run app.zen_browser.zen &
wid_zen=$(wait_for_window "zen") || exit 1
sleep 0.5
hyprctl dispatch movewindowpixel exact 1566 48,address:$wid_zen
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$wid_zen

### 4. Discord
log "Launching Discord..."
discord &
wid_discord=$(wait_for_window "discord") || exit 1
sleep 1.0
hyprctl dispatch movewindowpixel exact 3596 48,address:$wid_discord
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$wid_discord

log "All windows launched and positioned."


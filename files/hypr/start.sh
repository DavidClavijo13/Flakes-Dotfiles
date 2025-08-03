#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

echo "[start.sh] Starting wallpaper and background apps..."
swww-daemon --format xrgb 2>/dev/null &
sleep 0.3
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Helper to wait for a client by class and minimum size
wait_for_window() {
  local class=$1
  local min_width=$2
  local min_height=$3
  local win=""
  for i in {1..100}; do
    win=$(hyprctl clients -j | jq -r \
      --arg class "$class" \
      --argjson w "$min_width" \
      --argjson h "$min_height" '
        .[] | select(.class == $class and .size[0] >= $w and .size[1] >= $h) | .address' | head -n1)
    [ -n "$win" ] && echo "$win" && return
    sleep 0.1
  done
}

# ──────────── Launch and wait for each window ────────────

# 1. Top-left Ghostty
ghostty &
g1=$(wait_for_window "com.mitchellh.ghostty" 800 600)
hyprctl dispatch movewindowpixel exact 6 48,address:$g1
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$g1

# 2. Bottom-left Ghostty
ghostty &
g2=$(wait_for_window "com.mitchellh.ghostty" 800 600)
hyprctl dispatch movewindowpixel exact 6 1107,address:$g2
hyprctl dispatch resizewindowpixel exact 1548 1047,address:$g2

# 3. Zen Browser center
flatpak run app.zen_browser.zen &
zen=$(wait_for_window "zen" 800 600)
hyprctl dispatch movewindowpixel exact 1566 48,address:$zen
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen

# 4. Discord right side
discord &
discord_win=""
for i in {1..100}; do
  discord_win=$(hyprctl clients -j | jq -r '
    .[] | select(.class == "discord" and .title | test("Discord|Friends")) 
    | select(.size[0] >= 800 and .size[1] >= 600)
    | .address' | head -n1)
  [ -n "$discord_win" ] && break
  sleep 0.1
done

if [ -n "$discord_win" ]; then
  hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_win
  hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_win
fi


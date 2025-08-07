#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

staging_ws=99
target_ws=1

# 0) Start usual daemons (unchanged)
swww-daemon --format xrgb &>/dev/null & sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & ~/.config/hypr/toggle-waybar.sh & mako &

# 1) Launch the four
ghostty & ghostty & flatpak run app.zen_browser.zen & discord &
sleep 2

# 2) Identify windows (same robust selectors)
clients=$(hyprctl clients -j)
mapfile -t ghost_ids < <(echo "$clients" | jq -r \
  '[.[]|select(.class=="com.mitchellh.ghostty")]|sort_by(.at[1])|.[].address')
zen_id=$(echo "$clients" | jq -r '[.[]|select(.class=="zen")]|max_by(.size[1])|.address')
discord_id=$(echo "$clients" | jq -r '[.[]|select(.class=="discord")]|max_by(.size[1])|.address')

# 3) Send all to a clean staging workspace and make sure they are TILED
hyprctl dispatch workspace "$staging_ws"
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$staging_ws",address:"$id"
  # in case any ended up floating
  hyprctl dispatch setfloating disable,address:"$id"
done

# 4) Build the tree in a deterministic order
# Root: Ghostty TOP
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"

# Split vertically so left column vs right side is created
hyprctl dispatch layoutmsg togglesplit   # switch orientation once if needed

# 4a) Put Zen on the RIGHT of Ghostty top
hyprctl dispatch focuswindow address:"$zen_id"
hyprctl dispatch movewindow r

# 4b) Put Discord to the RIGHT of Zen
hyprctl dispatch focuswindow address:"$discord_id"
hyprctl dispatch movewindow r

# 4c) Put Ghostty BOTTOM under Ghostty TOP (left column stack)
hyprctl dispatch focuswindow address:"${ghost_ids[1]}"
hyprctl dispatch movewindow d

# Optional: nudge split ratios a bit
# (Tune these two lines to taste — they adjust the main vertical and the left stack ratio)
hyprctl dispatch splitratio 0.66     # make right side ~2/3 of width
hyprctl dispatch focuswindow address:"${ghost_ids[0]}"
hyprctl dispatch splitratio 0.50     # left column split 50/50

# 5) Move the fully‑built layout back to your real workspace
for id in "${ghost_ids[@]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch movetoworkspace "$target_ws",address:"$id"
done

# 6) Go to target workspace
hyprctl dispatch workspace "$target_ws"


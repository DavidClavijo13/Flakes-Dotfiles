#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# Start background apps
swww-daemon --format xrgb &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# Launch startup apps
ghostty &
sleep 0.5

ghostty &
sleep 0.5

flatpak run app.zen_browser.zen &
sleep 1

discord &

# Get ghostty and zen window addresses
mapfile -t ghostties < <(hyprctl clients -j | jq -r '.[] | select(.class == "com.mitchellh.ghostty") | .address')
zen=$(hyprctl clients -j | jq -r '.[] | select(.class == "zen") | .address')

# Float + position Ghostty top
hyprctl dispatch togglefloating address:${ghostties[0]}
hyprctl dispatch movewindowpixel exact 6 48,address:${ghostties[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghostties[0]}

# Float + position Ghostty bottom
hyprctl dispatch togglefloating address:${ghostties[1]}
hyprctl dispatch movewindowpixel exact 6 1107,address:${ghostties[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghostties[1]}

# Float + position Zen
hyprctl dispatch togglefloating address:$zen
hyprctl dispatch movewindowpixel exact 1566 48,address:$zen
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen

# ─────────────────────────────────────
# Wait for Discord’s *real* window
for i in {1..100}; do
  discord=$(hyprctl clients -j | jq -r '
    .[] | select(.class == "discord" and .title | test("Discord|Friends")) |
    sort_by(.size[0]) | last | .address')
  [[ -n "$discord" ]] && break
  sleep 0.1
done

if [[ -n "$discord" ]]; then
  hyprctl dispatch togglefloating address:$discord
  hyprctl dispatch movewindowpixel exact 3596 48,address:$discord
  hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord
fi


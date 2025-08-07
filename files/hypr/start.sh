#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"
set -e

# ───── 0) Background bits ─────
swww-daemon --format xrgb &>/dev/null || true &
sleep 0.2
swww img --transition-type simple "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator & disown || true
~/.config/hypr/toggle-waybar.sh & disown || true
mako & disown || true

# Make dwindle honor splits we set
hyprctl keyword dwindle:preserve_split true >/dev/null

# ───── 1) Launch the four ─────
ghostty &            # two terms (left column)
ghostty &
flatpak run app.zen_browser.zen &   # center column
discord &            # right column

# ───── 2) Let them map ─────
sleep 2

# ───── 3) One-shot clients ─────
clients="$(hyprctl clients -j)"

# 2 Ghostty (sorted by Y)
mapfile -t ghost_ids < <(
  printf '%s' "$clients" \
  | jq -r '[.[] | select(.class=="com.mitchellh.ghostty")] | sort_by(.at[1]) | .[].address'
)

# Tallest zen and tallest discord
zen_id=$(
  printf '%s' "$clients" \
  | jq -r '[.[] | select(.class=="zen")] | max_by(.size[1]) | .address'
)
discord_id=$(
  printf '%s' "$clients" \
  | jq -r '[.[] | select(.class=="discord")] | max_by(.size[1]) | .address'
)

# ───── 4) Float & pixel-place (exactly like your working step) ─────
for id in "${ghost_ids[0]}" "${ghost_ids[1]}" "$zen_id" "$discord_id"; do
  hyprctl dispatch togglefloating address:"$id"
done

hyprctl dispatch movewindowpixel exact 6    48,address:${ghost_ids[0]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[0]}

hyprctl dispatch movewindowpixel exact 6  1107,address:${ghost_ids[1]}
hyprctl dispatch resizewindowpixel exact 1548 1047,address:${ghost_ids[1]}

hyprctl dispatch movewindowpixel exact 1566 48,address:$zen_id
hyprctl dispatch resizewindowpixel exact 2018 2106,address:$zen_id

hyprctl dispatch movewindowpixel exact 3596 48,address:$discord_id
hyprctl dispatch resizewindowpixel exact 1518 2106,address:$discord_id

# ───── 5) Tile them in a fixed order + keep sizes (pseudo) ─────
# Make Zen the root (center column), then put Discord to the right, Ghosttys to the left (top/bottom)
# 5a) Zen → tiled, pseudo, root
hyprctl dispatch settiled address:$zen_id
hyprctl dispatch focuswindow address:$zen_id
hyprctl dispatch pseudo address:$zen_id            # keep its pixel size while tiled
hyprctl dispatch layoutmsg movetoroot              # make Zen the tree root

# 5b) Discord → tiled, pseudo, to the RIGHT of Zen
hyprctl dispatch settiled address:$discord_id
hyprctl dispatch focuswindow address:$discord_id
hyprctl dispatch pseudo address:$discord_id
hyprctl dispatch movewindow r

# 5c) Ghostty TOP → tiled, pseudo, to the LEFT of Zen
hyprctl dispatch settiled address:${ghost_ids[0]}
hyprctl dispatch focuswindow address:${ghost_ids[0]}
hyprctl dispatch pseudo address:${ghost_ids[0]}
hyprctl dispatch movewindow l

# Ensure left split is vertical for the two Ghosttys
hyprctl dispatch layoutmsg togglesplit    # if it was side-by-side, flip once to top/bottom

# 5d) Ghostty BOTTOM → tiled, pseudo, left + DOWN (stack under top)
hyprctl dispatch settiled address:${ghost_ids[1]}
hyprctl dispatch focuswindow address:${ghost_ids[1]}
hyprctl dispatch pseudo address:${ghost_ids[1]}
hyprctl dispatch movewindow l
hyprctl dispatch movewindow d


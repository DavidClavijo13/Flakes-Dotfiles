#!/usr/bin/env bash
export PATH="$HOME/.nix-profile/bin:/run/current-system/profile/bin:$PATH"

# ─────────── Start background daemons & wallpaper ───────────
swww-daemon --format xrgb &>/dev/null &
sleep 0.2
swww img --transition-type simple \
    "$HOME/Downloads/wp4472154-5120x2160-wallpapers.jpg" &
nm-applet --indicator &
~/.config/hypr/toggle-waybar.sh &
mako &

# ─────────── Listen for the four windows ───────────
(
  ghost_seen=0
  placed=0

  # Subscribe to the "openwindow" event, get JSON lines
  hyprctl subscribe openwindow |
  jq -c 'select(.mapped == 1)' |
  while read -r ev; do
    cls   =$(jq -r '.class'     <<<"$ev")
    ws    =$(jq -r '.workspace' <<<"$ev")
    addr  =$(jq -r '.address'   <<<"$ev")

    # ignore windows on other workspaces
    [ "$ws" -ne 1 ] && continue

    case "$cls" in

      # ─ Ghostty 1 (top-left) ─
      com.mitchellh.ghostty)
        ghost_seen=$((ghost_seen+1))
        if [ $ghost_seen -eq 1 ]; then
          hyprctl dispatch togglefloating address:$addr
          hyprctl dispatch movewindowpixel exact 6 48,address:$addr
          hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr
        else
          # Ghostty 2 (bottom-left)
          hyprctl dispatch togglefloating address:$addr
          hyprctl dispatch movewindowpixel exact 6 1107,address:$addr
          hyprctl dispatch resizewindowpixel exact 1548 1047,address:$addr
        fi
        placed=$((placed+1))
        ;;

      # ─ Zen Browser (center) ─
      zen)
        hyprctl dispatch togglefloating address:$addr
        hyprctl dispatch movewindowpixel exact 1566 48,address:$addr
        hyprctl dispatch resizewindowpixel exact 2018 2106,address:$addr
        placed=$((placed+1))
        ;;

      # ─ Discord (right) ─
      discord)
        hyprctl dispatch togglefloating address:$addr
        hyprctl dispatch movewindowpixel exact 3596 48,address:$addr
        hyprctl dispatch resizewindowpixel exact 1518 2106,address:$addr
        placed=$((placed+1))
        ;;

    esac

    # once we've placed all four, stop listening
    [ "$placed" -ge 4 ] && break
  done
) &  # run subscription in background

# ─────────── Actually launch the apps ───────────
ghostty &
ghostty &
flatpak run app.zen_browser.zen &
discord &


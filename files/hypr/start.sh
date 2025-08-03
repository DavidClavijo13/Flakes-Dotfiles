#!/usr/bin/env bash

set -euo pipefail

# Wallpaper and services (customize if needed)
swww init &
swww img ~/Downloads/wp4472154-5120x2160-wallpapers.jpg &
nm-applet --indicator &
waybar &
mako &

# Define window-launching helper function
launch_and_wait() {
  $@ &
  pid=$!
  while ! hyprctl clients | grep -q "pid: $pid"; do sleep 0.1; done
  echo $pid
}

# Ensure workspace 1 is clean and selected
hyprctl dispatch workspace 1
hyprctl dispatch killactive # run multiple times if multiple windows persist

# First Ghostty terminal (top-left)
pid1=$(launch_and_wait ghostty)
hyprctl dispatch movewindowpixel exact 6 48,pid:$pid1
hyprctl dispatch resizewindowpixel exact 1548 1047,pid:$pid1

# Second Ghostty terminal (bottom-left)
pid2=$(launch_and_wait ghostty)
hyprctl dispatch movewindowpixel exact 6 1107,pid:$pid2
hyprctl dispatch resizewindowpixel exact 1548 1047,pid:$pid2

# Zen Browser (center)
pid3=$(launch_and_wait zen)
hyprctl dispatch movewindowpixel exact 1566 48,pid:$pid3
hyprctl dispatch resizewindowpixel exact 2018 2106,pid:$pid3

# Discord (right)
pid4=$(launch_and_wait discord)
hyprctl dispatch movewindowpixel exact 3596 48,pid:$pid4
hyprctl dispatch resizewindowpixel exact 1518 2106,pid:$pid4


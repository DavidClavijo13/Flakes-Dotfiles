#!/usr/bin/env bash
PIDFILE="$HOME/.cache/waybar.pid"

# If we have a recorded PID and the process is alive, kill it
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  kill "$(cat "$PIDFILE")"
  rm "$PIDFILE"
  exit 0
fi

# Otherwise, start Waybar and save its PID
waybar &
echo $! > "$PIDFILE"

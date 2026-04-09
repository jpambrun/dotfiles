#!/bin/sh

output="$(xrandr --query | awk '$2 == "connected" && $1 != "eDP-1" { print $1; exit }')"

if [ -z "$output" ]; then
    xrandr --output eDP-1 --auto --primary
    exit 0
fi

# xrandr --output "$output" --set "max bpc" 8 2>/dev/null
# xrandr --output "$output" --mode 1920x1080 --rate 60.00
# sleep 1
xrandr --output "$output" --set "max bpc" 8 --primary --mode 3840x2160 --rate 60.00 --output eDP-1 --off

# Sway Setup Notes

## Install

Install the Sway desktop, Wayland utilities, monitor tools, and Handy paste support:

```nu
sudo pacman -S --needed sway waybar wofi mako swaybg swayidle swaylock grim slurp wl-clipboard xdg-desktop-portal-wlr xorg-xwayland jq wdisplays nwg-displays kanshi wtype pavucontrol playerctl brightnessctl power-profiles-daemon
```

Install Handy:

```nu
yay -S handy-bin
```

## Handy Speech-to-Text

In the Handy UI, set:

```text
Settings > Advanced > Typing Tool > wtype
Settings > Advanced > Paste Method > Clipboard / Ctrl+V
Settings > Advanced > Overlay Position > None
```

For terminals, switch the paste method to:

```text
Settings > Advanced > Paste Method > Ctrl+Shift+V
```

If the wrong text is pasted, increase:

```text
Settings > Debug > Paste Delay
```

Try `100ms` to `200ms`.

## Notes

Under Sway, `DISPLAY=:0` usually means Xwayland compatibility is available. It does not mean the session is Xorg.

Wayland replacements for common i3/X11 tools:

```text
xrandr      -> swaymsg output, wdisplays, nwg-displays, kanshi
xclip       -> wl-copy, wl-paste
maim/scrot  -> grim, slurp
feh         -> output * bg ... fill
i3lock      -> swaylock
xset        -> swayidle
dunst       -> mako
picom       -> built into Sway/wlroots
```

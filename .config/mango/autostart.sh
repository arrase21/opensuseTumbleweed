#!/bin/bash

set +e
# obs
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots >/dev/null 2>&1
# notify===========================================================================================
# swaync -c ~/.config/mango/swaync/config.json -s ~/.config/mango/swaync/style.css >/dev/null 2>&1 &
# swaync &
mako &
# wallpaper=====================================================================================
# swaybg -i ~/Pictures/wallpapers/totoro-catppuccin.png >/dev/null 2>&1 &
swww-daemon &
# top bar=======================================================================================
waybar -c ~/.config/mango/waybar/config -s ~/.config/mango/waybar/style.css >/dev/null 2>&1 &
# clipboard content manager=====================================================================
wl-clip-persist --clipboard regular --reconnect-tries 0 >/dev/null 2>&1 &
wl-paste --type text --watch cliphist store >/dev/null 2>&1 &
# Permission authentication
/usr/libexec/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &
eww daemon &
# 自启动脚本 仅作参考
# ime input
fcitx5 --replace -d >/dev/null 2>&1 &

# dms run >/dev/null 2>&1 &

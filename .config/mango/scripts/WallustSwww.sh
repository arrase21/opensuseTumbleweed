#!/usr/bin/env bash
# WallustSwww.sh → VERSIÓN DIOS (0% spam, 100% colores, 0% fallos)

# Silencio ABSOLUTO desde el inicio
exec 1>/dev/null 2>&1

cache_dir="$HOME/.cache/swww/"
current_monitor=$(wlr-randr | grep -m1 -o '^[^ ]*')
cache_file="${cache_dir}${current_monitor}"

[[ -f "$cache_file" ]] || exit 1
wallpaper_path=$(grep -m1 -v lanczos3 "$cache_file")
[[ -f "$wallpaper_path" ]] || exit 1

# wallust con prioridad alta + silencio total
nice -n -10 wallust run "$wallpaper_path" -s &

# Waybar recarga (USR2 es más suave que USR1)
pgrep -x waybar >/dev/null && pkill -SIGUSR2 waybar &

# Otros daemons que usan wallust
pkill -USR2 swaync-client 2>/dev/null || swaync-client -rs &
"$HOME/.config/mango/scripts/mako.sh" 2>/dev/null || true

exit 0

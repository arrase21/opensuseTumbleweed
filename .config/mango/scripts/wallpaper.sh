#!/usr/bin/env bash
set -e

THEME="$HOME/.config/current/theme/"
WALLPAPERS_DIR="$THEME/wallpapers"
SCRIPTSDIR="$HOME/.config/mango/scripts"
WAYBAR_CSS_DEST="$HOME/.config/mango/waybar/style.css"
WAYBAR_CSS_SRC="$THEME/waybar.css"

if [[ -d "$WALLPAPERS_DIR" && -n "$(ls -A "$WALLPAPERS_DIR" 2>/dev/null)" ]]; then
  mapfile -t WALLPAPERS < <(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)
  
  if [[ ${#WALLPAPERS[@]} -gt 0 ]]; then
    WALLPAPER="${WALLPAPERS[$(( RANDOM % ${#WALLPAPERS[@]} ))]}"

    cp "$WALLPAPER" ~/.config/wall.png

    swww img "$WALLPAPER" --transition-type wipe --transition-fps 60 --transition-duration 2

    wallust run "$WALLPAPER" -s >/dev/null 2>&1
    sleep 0.8

    if [[ -f "$WAYBAR_CSS_SRC" ]]; then
      cp -f "$WAYBAR_CSS_SRC" "$WAYBAR_CSS_DEST"
    fi

    pkill -SIGUSR2 waybar 2>/dev/null || {
      pkill waybar
      sleep 0.3
      waybar -c ~/.config/mango/waybar/config -s "$WAYBAR_CSS_DEST" >/dev/null 2>&1 &
    }
    notify-send "Tema completo" "$THEME_NAME\n$(basename "$WALLPAPER")" -i "$WALLPAPER"
    # pkill -USR2 swaync-client 2>/dev/null || swaync-client -rs &
    "$SCRIPTSDIR/mako.sh" 2>/dev/null || true
  fi
else
  [[ -f "$WAYBAR_CSS_SRC" ]] && cp -f "$WAYBAR_CSS_SRC" "$WAYBAR_CSS_DEST" && pkill -SIGUSR2 waybar
fi

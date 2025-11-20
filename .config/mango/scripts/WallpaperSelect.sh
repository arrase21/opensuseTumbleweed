#!/usr/bin/env bash

# Directorio de wallpapers
wallDIR="$HOME/Pictures/wallpapers"
iDIR="$HOME/.config/swaync/images" # Para notificaciones
rofi_theme="$HOME/.config/mango/rofi/config-wallpaper.rasi"
SCRIPTSDIR="$HOME/.config/mango/scripts"

# Configuración de transiciones de swww
TYPE="any"
SWWW_PARAMS="--transition-type $TYPE"

# Obtener lista de imágenes (excluyendo videos)
mapfile -d '' PICS < <(find -L "${wallDIR}" -maxdepth 1 -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" \) -print0)

menu() {
  for pic in "${PICS[@]}"; do
    name=$(basename "$pic")
    printf "%s\x00icon\x1f%s\n" "${name%.*}" "$pic"
  done
}

main() {

  if pidof rofi >/dev/null; then
    pkill rofi
  fi

  choice=$(menu | rofi -i -show -dmenu -config "$rofi_theme" | xargs)
  [[ -z "$choice" ]] && echo "No se seleccionó ninguna imagen." && exit 0

  choice_basename=$(basename "$choice" | sed 's/\(.*\)\.[^.]*$/\1/')
  selected_file=$(find "$wallDIR" -maxdepth 1 -iname "$choice_basename.*" -print -quit)

  [[ -z "$selected_file" ]] && notify-send -i "$iDIR/error.png" "Error" "No se encontró la imagen seleccionada" && exit 1

  # Matar daemons de fondo previos y reiniciar swww
  # swww kill 2>/dev/null
  if ! pgrep -x "swww-daemon" >/dev/null; then
    swww-daemon --format argb &
    sleep 0.1
  fi

  # Cambiar wallpaper y ejecutar wallust (bloqueante)
  cp "$selected_file" ~/.config/wall.png
  swww img "$selected_file" $SWWW_PARAMS
  "$SCRIPTSDIR/WallustSwww.sh"
  wallust run "$selected_file" -s  # ← sin '&' para esperar

  # Reiniciar Waybar con nuevo esquema de colores
  WALLUST_CACHE="$HOME/.config/mango/waybar/wallust"
  WAYBAR_STYLE_DEST="$HOME/.config/mango/waybar/style.css"

# Recargar Waybar
  if pgrep -x waybar >/dev/null; then
    pkill -USR2 waybar
  else
    waybar -c ~/.config/mango/waybar/config -s "$WAYBAR_STYLE_DEST" >/dev/null 2>&1 &
  fi

# Recargar notificaciones
pkill -USR2 swaync-client 2>/dev/null || swaync-client -rs &

notify-send "Wallpaper cambiado" "$choice_basename" -i "$selected_file"
"$SCRIPTSDIR/mako.sh" 2>/dev/null || true

}

main

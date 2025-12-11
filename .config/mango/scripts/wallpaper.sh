#!/usr/bin/env bash
# Comentar set -e para mejor manejo de errores
# set -e

# Asegurar variables de entorno
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Expandir PATH para incluir todas las ubicaciones comunes (especialmente cargo)
export PATH="$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

THEME_LINK="$HOME/.config/current/theme"
THEME="$(readlink -f "$THEME_LINK" 2>/dev/null || echo "$THEME_LINK")"
WALLPAPERS_DIR="$THEME/wallpapers"
SCRIPTSDIR="$HOME/.config/mango/scripts"
WAYBAR_CSS_DEST="$HOME/.config/mango/waybar/style.css"
WAYBAR_CSS_SRC="$THEME/waybar.css"
WAYBAR_CONFIG="$HOME/.config/mango/waybar/config"
LOG_FILE="/tmp/wallpaper-debug.log"

# Función de logging
log_msg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_msg "=========================================="
log_msg "Iniciando wallpaper.sh"
log_msg "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
log_msg "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
log_msg "THEME_LINK: $THEME_LINK"
log_msg "THEME: $THEME"
log_msg "WALLPAPERS_DIR: $WALLPAPERS_DIR"
log_msg "=========================================="

# Verificar que el tema existe
if [[ ! -d "$THEME" ]]; then
  log_msg "ERROR: Tema no existe: $THEME"
  exit 1
fi

# Cambiar wallpaper si hay wallpapers disponibles
if [[ -d "$WALLPAPERS_DIR" && -n "$(ls -A "$WALLPAPERS_DIR" 2>/dev/null)" ]]; then
  log_msg "Buscando wallpapers en: $WALLPAPERS_DIR"
  
  mapfile -t WALLPAPERS < <(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)
  
  if [[ ${#WALLPAPERS[@]} -gt 0 ]]; then
    WALLPAPER="${WALLPAPERS[$(( RANDOM % ${#WALLPAPERS[@]} ))]}"
    log_msg "Wallpaper seleccionado: $WALLPAPER"
    
    # Copiar wallpaper
    log_msg "Copiando wallpaper a ~/.config/wall.png"
    if cp "$WALLPAPER" ~/.config/wall.png; then
      log_msg "✓ Wallpaper copiado"
    else
      log_msg "✗ Error copiando wallpaper"
    fi
    
    # Aplicar wallpaper con swww
    log_msg "Aplicando wallpaper con swww..."
    if command -v swww >/dev/null 2>&1; then
      if swww img "$WALLPAPER" --transition-type wipe --transition-fps 60 --transition-duration 2 2>&1 | tee -a "$LOG_FILE"; then
        log_msg "✓ swww ejecutado"
      else
        log_msg "✗ swww falló"
      fi
    else
      log_msg "✗ swww no encontrado"
    fi
    
    # Ejecutar wallust
    log_msg "Ejecutando wallust..."
    if command -v wallust >/dev/null 2>&1; then
      if wallust run "$WALLPAPER" -s >/dev/null 2>&1; then
        log_msg "✓ wallust ejecutado"
      else
        log_msg "✗ wallust falló (continuando...)"
      fi
    else
      log_msg "✗ wallust no encontrado"
    fi
    
    # Esperar a que wallust termine
    sleep 1
  else
    log_msg "No se encontraron wallpapers"
  fi
else
  log_msg "No hay directorio de wallpapers o está vacío"
fi

# Aplicar CSS de waybar
log_msg "Procesando CSS de waybar..."
if [[ -f "$WAYBAR_CSS_SRC" ]]; then
  log_msg "Copiando CSS: $WAYBAR_CSS_SRC -> $WAYBAR_CSS_DEST"
  if cp -f "$WAYBAR_CSS_SRC" "$WAYBAR_CSS_DEST"; then
    log_msg "✓ CSS copiado"
  else
    log_msg "✗ Error copiando CSS"
  fi
else
  log_msg "✗ CSS no encontrado: $WAYBAR_CSS_SRC"
fi

# Recargar waybar
log_msg "Recargando waybar..."

# Verificar si waybar está corriendo
if pgrep -x waybar >/dev/null; then
  log_msg "Waybar está corriendo, matando proceso..."
  pkill -9 waybar 2>/dev/null
  sleep 2
  log_msg "Waybar terminado"
else
  log_msg "Waybar no estaba corriendo"
fi

# Esperar a que termine completamente
WAIT_COUNT=0
while pgrep -x waybar >/dev/null && [[ $WAIT_COUNT -lt 5 ]]; do
  log_msg "Esperando a que waybar termine... ($WAIT_COUNT)"
  sleep 1
  ((WAIT_COUNT++))
done

# Relanzar waybar
log_msg "Relanzando waybar..."
log_msg "Config: $WAYBAR_CONFIG"
log_msg "CSS: $WAYBAR_CSS_DEST"

# Verificar que los archivos existen
if [[ ! -f "$WAYBAR_CONFIG" ]]; then
  log_msg "✗ ERROR: Config no existe: $WAYBAR_CONFIG"
fi

if [[ ! -f "$WAYBAR_CSS_DEST" ]]; then
  log_msg "✗ ERROR: CSS no existe: $WAYBAR_CSS_DEST"
fi

# Relanzar waybar con variables de entorno explícitas
if WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
   XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
   waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_CSS_DEST" >> "$LOG_FILE" 2>&1 &
then
  WAYBAR_PID=$!
  log_msg "✓ Waybar lanzado con PID: $WAYBAR_PID"
  
  # Verificar que inició correctamente
  sleep 1
  if pgrep -x waybar >/dev/null; then
    log_msg "✓ Waybar corriendo correctamente"
  else
    log_msg "✗ ERROR: Waybar no está corriendo después de lanzarlo"
    log_msg "Últimas líneas del log de waybar:"
    tail -20 "$LOG_FILE"
  fi
else
  log_msg "✗ ERROR al lanzar waybar"
fi

# Notificación
if [[ -n "$WALLPAPER" ]]; then
  log_msg "Enviando notificación..."
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Tema completo" "$(basename "$THEME")\n$(basename "$WALLPAPER")" -i "$WALLPAPER" 2>&1 | tee -a "$LOG_FILE"
  else
    log_msg "notify-send no encontrado"
  fi
fi

# Ejecutar mako.sh si existe
if [[ -f "$SCRIPTSDIR/mako.sh" ]]; then
  log_msg "Ejecutando mako.sh..."
  "$SCRIPTSDIR/mako.sh" 2>&1 | tee -a "$LOG_FILE" || log_msg "mako.sh falló"
fi

log_msg "wallpaper.sh completado"
log_msg "=========================================="

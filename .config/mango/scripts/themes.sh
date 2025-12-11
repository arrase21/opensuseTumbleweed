#!/usr/bin/env bash
# Comentar set -e temporalmente para debug
# set -e

# Asegurar variables de entorno
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Expandir PATH para incluir todas las ubicaciones comunes (especialmente cargo)
export PATH="$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

THEME_DIR="$HOME/.config/themes"
CURRENT_THEME_DIR="$HOME/.config/current/theme"
NVIM_THEME_FILE="$HOME/.config/nvim/plugin/40_plugins.lua"
SCR="$HOME/.config/mango/scripts"
LOG_FILE="/tmp/themes-debug.log"

USAGE="
Usage: $0 [OPTION] [ARGUMENT]
Options:
  -l, --list             List available themes
  -c, --change THEME     Change to specified THEME
  -p, --prompt           Change theme with interactive prompt
  -h, --help             Show this help message
"

# Función para logging
log_msg() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

list_themes() {
  find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
}

change_theme() {
  local chosen="$1"
  
  log_msg "=========================================="
  log_msg "Iniciando cambio de tema: $chosen"
  log_msg "Usuario: $USER"
  log_msg "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
  log_msg "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
  log_msg "=========================================="
  
  THEME_PATH="$THEME_DIR/$chosen"
  THEME_NAME="$chosen"
  THEME_FILE="$THEME_PATH/${THEME_NAME}.ini"
  
  if [[ ! -d "$THEME_PATH" ]]; then
    log_msg "ERROR: no existe el tema '$chosen'"
    echo "Error: no existe el tema '$chosen'"
    echo -e "Temas disponibles:\n$(list_themes)"
    exit 1
  fi
  
  log_msg "Creando directorios..."
  mkdir -p "$HOME/.config/foot" "$(dirname "$CURRENT_THEME_DIR")"
  
  log_msg "Creando symlink: $THEME_PATH -> $CURRENT_THEME_DIR"
  ln -nsf "$THEME_PATH" "$CURRENT_THEME_DIR"
  
  log_msg "Copiando archivo de tema: $THEME_FILE -> $HOME/.config/foot/foot.ini"
  if [[ -f "$THEME_FILE" ]]; then
    cp -v "$THEME_FILE" "$HOME/.config/foot/foot.ini" 2>&1 | tee -a "$LOG_FILE"
  else
    log_msg "ADVERTENCIA: $THEME_FILE no existe"
  fi
  
  log_msg "Ejecutando wallpaper.sh..."
  if [[ -x "$SCR/wallpaper.sh" ]]; then
    # Ejecutar wallpaper.sh y capturar su salida
    if "$SCR/wallpaper.sh" 2>&1 | tee -a "$LOG_FILE"; then
      log_msg "✓ wallpaper.sh ejecutado exitosamente"
    else
      EXIT_CODE=$?
      log_msg "✗ wallpaper.sh falló con código: $EXIT_CODE"
      log_msg "Continuando de todas formas..."
    fi
  else
    log_msg "ERROR: $SCR/wallpaper.sh no existe o no es ejecutable"
    log_msg "Verificando existencia:"
    ls -la "$SCR/wallpaper.sh" 2>&1 | tee -a "$LOG_FILE" || log_msg "Archivo no encontrado"
  fi
  
  # Esperar un momento para que los procesos terminen
  sleep 1
  
  log_msg "Tema cambiado a '$chosen'"
  log_msg "=========================================="
  echo "Tema cambiado a '$chosen'"
  
  # Mostrar resumen de procesos
  log_msg "Procesos waybar activos:"
  pgrep -a waybar 2>&1 | tee -a "$LOG_FILE" || log_msg "No hay waybar corriendo"
}

case "$1" in
  --list|-l)
    echo -e "Temas disponibles:\n$(list_themes)"
    ;;
  --change|-c)
    chosen="$2"
    if [[ -z "$chosen" ]]; then
      echo "No se especificó tema."
      exit 1
    fi
    change_theme "$chosen"
    ;;
  --prompt|-p)
    mapfile -t THEMES < <(list_themes)
    if [[ ${#THEMES[@]} -eq 0 ]]; then
      echo "No hay temas en $THEME_DIR"
      exit 1
    fi
    echo "Selecciona un tema:"
    PS3="Opción: "
    select chosen in "${THEMES[@]}" "Cancelar"; do
      if [[ "$chosen" == "Cancelar" ]]; then
        echo "Cancelado."
        exit 0
      elif [[ -n "$chosen" ]]; then
        change_theme "$chosen"
        break
      else
        echo "Opción inválida."
      fi
    done
    ;;
  --help|-h|"")
    echo "$USAGE"
    ;;
  *)
    echo -e "Error: bandera desconocida '$1'\n$USAGE"
    exit 1
    ;;
esac

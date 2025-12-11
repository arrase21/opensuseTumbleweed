#!/usr/bin/env bash

# Script para forzar recarga completa de waybar
# Úsalo al final de wallpaper.sh o themes.sh

WAYBAR_CONFIG="$HOME/.config/mango/waybar/config"
WAYBAR_CSS="$HOME/.config/mango/waybar/style.css"

echo "=== $(date) Force reload waybar ===" >> /tmp/waybar-reload.log

# Asegurar variables de entorno
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Matar todos los procesos de waybar con SIGKILL
pkill -9 waybar 2>/dev/null
echo "Waybar terminado" >> /tmp/waybar-reload.log

# Esperar a que realmente termine
sleep 2

# Verificar que no quede ningún proceso
while pgrep waybar >/dev/null; do
  echo "Waybar aún corriendo, esperando..." >> /tmp/waybar-reload.log
  pkill -9 waybar
  sleep 1
done

echo "Waybar completamente terminado" >> /tmp/waybar-reload.log

# Relanzar waybar con nohup para desacoplarlo completamente
nohup waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_CSS" \
  >> /tmp/waybar-reload.log 2>&1 &

WAYBAR_PID=$!
echo "Waybar relanzado con PID: $WAYBAR_PID" >> /tmp/waybar-reload.log

# Dar tiempo para que inicie
sleep 1

if pgrep waybar >/dev/null; then
  echo "✓ Waybar corriendo exitosamente" >> /tmp/waybar-reload.log
else
  echo "✗ ERROR: Waybar no inició" >> /tmp/waybar-reload.log
fi

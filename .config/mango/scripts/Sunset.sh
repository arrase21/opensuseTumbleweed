#!/usr/bin/env bash
set +e

# Verifica si wlsunset ya está corriendo
if pgrep -x "wlsunset" >/dev/null; then
  # Si está corriendo, lo detiene (modo noche OFF)
  pkill wlsunset >/dev/null 2>&1
else
  # Si no está corriendo, lo inicia (modo noche ON)
  wlsunset >/dev/null 2>&1 &
fi

exit 0

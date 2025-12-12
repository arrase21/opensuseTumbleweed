#!/usr/bin/env bash
set +e

# Verifica si wlsunset ya está corriendo
if pgrep -x "wlsunset" >/dev/null; then
  pkill wlsunset >/dev/null 2>&1
else
  wlsunset >/dev/null 2>&1 &
fi

exit 0

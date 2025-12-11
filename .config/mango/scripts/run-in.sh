# ~/.config/mango/scripts/run-in-env.sh
#!/usr/bin/env bash
# Fuerza las variables necesarias para que todo funcione desde atajos
export XDG_RUNTIME_DIR="/run/user/$UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

exec "$@"

#!/bin/bash

WINDOW="music-widget"
STATE_FILE="/tmp/eww-music-widget-state"

# Método 1: Intentar ping (más rápido)
if eww ping 2>/dev/null; then
    # Si eww responde, preguntamos por ventanas activas
    if eww list-windows | grep -q "^$WINDOW: true$"; then
        eww close "$WINDOW"
        echo "closed" > "$STATE_FILE"
        exit 0
    fi
fi

# Método 2: Fallback con archivo de estado
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "open" ]; then
    eww close "$WINDOW" 2>/dev/null || true
    echo "closed" > "$STATE_FILE"
else
    eww open "$WINDOW"
    echo "open" > "$STATE_FILE"
fi

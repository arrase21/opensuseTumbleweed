#!/bin/bash

# Expandir PATH para incluir cargo (gyr está escrito en Rust)
export PATH="$HOME/.cargo/bin:$HOME/go/bin:$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

APP_ID="gyr-launcher"

if pgrep -f "foot.*--app-id=${APP_ID}" >/dev/null; then
    pkill -f "foot.*--app-id=${APP_ID}"
else
    foot --app-id="${APP_ID}" -e gyr &
fi

#!/usr/bin/env bash
# Recarga EWWII después de wallust

THEME_FILE="$HOME/.config/ewwii/theme.scss"
EWW_BIN="eww"   # o "ewwii" si tu binario se llama así

# Compila si usas CSS
if [[ -f "$HOME/.config/ewwii/theme.scss" && -f "$HOME/.config/ewwii/theme.css" ]]; then
    sassc "$HOME/.config/ewwii/theme.scss" "$HOME/.config/ewwii/theme.css"
fi

# Cierra todas las ventanas de eww
$EWW_BIN kill

# Abre tu ventana principal
# → CAMBIA "bar" por el nombre correcto (te pediré comando)
$EWW_BIN open bar & disown


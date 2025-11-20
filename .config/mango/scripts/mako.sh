
#!/usr/bin/env bash
set -e

# 📁 Rutas
WALLUST_COLORS="$HOME/.config/mango/waybar/wallust/colors-waybar.css"
MAKO_CONFIG="$HOME/.config/mako/config"

# 🎨 Función para extraer colores hex
extract_color() {
  grep -Po "(?<=@define-color $1 )#[0-9A-Fa-f]{6}" "$WALLUST_COLORS" | head -n1
}

# 🎨 Función especial para rgba() -> #RRGGBB
extract_rgba_to_hex() {
  rgba=$(grep -Po "(?<=@define-color $1 )rgba\([^)]+\)" "$WALLUST_COLORS" | head -n1)
  if [[ -n "$rgba" ]]; then
    # Extraer los 3 primeros valores numéricos
    r=$(echo "$rgba" | grep -Po '\d+' | sed -n '1p')
    g=$(echo "$rgba" | grep -Po '\d+' | sed -n '2p')
    b=$(echo "$rgba" | grep -Po '\d+' | sed -n '3p')
    printf "#%02x%02x%02x" "$r" "$g" "$b"
  fi
}

# 📦 Extraer colores
primary=$(extract_color color2)
surface=$(extract_color color5)
on_surface=$(extract_color foreground)
error=$(extract_color color1)

# Si background está en rgba(), convertirlo a hex
if [[ -z "$surface" ]]; then
  surface=$(extract_rgba_to_hex background)
fi

# Usamos el mismo fondo para on_primary
on_primary="$surface"

# ✅ Validación
for var in primary surface on_surface error; do
  if [ -z "${!var}" ]; then
    # echo "❌ Falta color: $var (no encontrado en $WALLUST_COLORS)"
    exit 1
  fi
done

# 📝 Generar config para mako
cat > "$MAKO_CONFIG" <<EOF
# 🦊 Config de Mako generado automáticamente por Wallust
# $(date)

font=JetBrainsMono Nerd Font 10
max-visible=10
# default-timeout=10000
ignore-timeout=1

background-color=${surface}ee
text-color=${on_surface}
border-color=${primary}
progress-color=${primary}
margin=1
padding=1
border-size=4
border-radius=8

[urgency=high]
border-color=${error}

EOF

# 🔄 Recargar Mako
if pgrep -x mako >/dev/null; then
  makoctl reload || { pkill mako && mako & }
else
  mako &
fi

# echo "✅ Mako actualizado con colores de Wallust"

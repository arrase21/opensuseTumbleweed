#!/usr/bin/env bash
# Script para generar waybar.css desde archivos .ini

THEMES_DIR="$HOME/.config/themes"

echo "🎨 Generando archivos waybar.css para todos los temas..."
echo

for theme_dir in "$THEMES_DIR"/*; do
  if [[ -d "$theme_dir" ]]; then
    theme_name=$(basename "$theme_dir")
    ini_file="$theme_dir/${theme_name}.ini"
    waybar_css="$theme_dir/waybar.css"
    
    # Si ya existe waybar.css, omitir (como osakagreen)
    if [[ -f "$waybar_css" ]]; then
      echo "✓  $theme_name ya tiene waybar.css"
      continue
    fi
    
    # Verificar que existe el .ini
    if [[ ! -f "$ini_file" ]]; then
      echo "❌ No se encontró $ini_file"
      continue
    fi
    
    # Extraer colores del .ini
    foreground=$(grep "^foreground" "$ini_file" | cut -d'=' -f2 | tr -d ' ' | head -n1)
    background=$(grep "^background" "$ini_file" | cut -d'=' -f2 | tr -d ' ' | head -n1)
    
    if [[ -z "$foreground" ]] || [[ -z "$background" ]]; then
      echo "⚠️  No se pudieron extraer colores de $theme_name"
      continue
    fi
    
    # Crear waybar.css
    cat > "$waybar_css" << EOF
/* Colores para el tema $theme_name */
@define-color foreground $foreground;
@define-color background $background;
EOF
    
    echo "✅ Generado: $theme_name/waybar.css"
    echo "   foreground: $foreground"
    echo "   background: $background"
    echo
  fi
done

echo "🎉 ¡Proceso completado!"

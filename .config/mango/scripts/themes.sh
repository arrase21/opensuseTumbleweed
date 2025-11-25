#!/usr/bin/env bash
set -e

# 🎨 Arte ASCII
ascii_art="
  ▗▄▄▄▖▗▖ ▗▖▗▄▄▄▖▗▖  ▗▖▗▄▄▄▖ ▗▄▄▖
    █  ▐▌ ▐▌▐▌   ▐▛▚▞▜▌▐▌   ▐▌   
    █  ▐▛▀▜▌▐▛▀▀▘▐▌  ▐▌▐▛▀▀▘ ▝▀▚▖
    █  ▐▌ ▐▌▐▙▄▄▖▐▌  ▐▌▐▙▄▄▖▗▄▄▞▘
"
if command -v gum >/dev/null 2>&1; then
  gum style --foreground 212 --border none --margin "1 2" --padding "1 3" --align center "$ascii_art"
else
  echo -e "\n\e[1;35m$ascii_art\e[0m\n"
fi

# === PATH ===
THEMES_DIR="$HOME/.config/themes/"
CURRENT_THEME_DIR="$HOME/.config/current/theme"
NVIM_THEME_FILE="$HOME/.config/nvim/plugin/40_plugins.lua"
SCR="$HOME/.config/mango/scripts"

# ===  THEME CHOICE ===
THEMES=($(ls "$THEMES_DIR" 2>/dev/null))
[[ ${#THEMES[@]} -eq 0 ]] && { echo "No hay temas"; exit 1; }

THEME_NAME=$(gum filter --header "🔍 Search or Select" \
                          --prompt "➜ " \
                          --height 15 \
                          --placeholder "Write..." \
                          "${THEMES[@]}")
THEME_NAME=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
THEME_PATH="$THEMES_DIR/$THEME_NAME"
THEME_FILE="$THEME_PATH/${THEME_NAME}.ini"
WAYBAR_CSS_SRC="$THEME_PATH/waybar.css"

# ===  THEME  ===
mkdir -p "$HOME/.config/foot" "$(dirname "$CURRENT_THEME_DIR")" "$(dirname "$WAYBAR_CSS_DEST")"
ln -nsf "$THEME_PATH" "$CURRENT_THEME_DIR" > /dev/null
cp -v "$THEME_FILE" "$HOME/.config/foot/foot.ini"

"$SCR/wallpaper.sh" 
# # === CAMBIAR TEMA DE NEOVIM ===
if gum confirm "¿Deseas también cambiar el tema de Neovim?"; then
  if [[ -f "$NVIM_THEME_FILE" ]]; then
    # Menú para elegir tema de Neovim
    NVIM_THEME=$(gum choose \
      "kanagawa-wave" \
      "tokyonight" \
      "solarized-osaka" \
      "gruvbox" \
      --header "🎨 Selecciona tema de Neovim" --height 10)

    if [[ -n "$NVIM_THEME" ]]; then
      # Crear backup
      cp "$NVIM_THEME_FILE" "${NVIM_THEME_FILE}.bak"

      # Comentar todos los temas
      sed -i 's/^[[:space:]]*vim\.cmd("colorscheme/  -- vim.cmd("colorscheme/g' "$NVIM_THEME_FILE"

      # Descomentar el tema seleccionado
      sed -i "s/^[[:space:]]*--[[:space:]]*vim\.cmd(\"colorscheme ${NVIM_THEME}\")/  vim.cmd(\"colorscheme ${NVIM_THEME}\")/g" "$NVIM_THEME_FILE"

      echo "✅ Tema de Neovim cambiado a '$NVIM_THEME'"
    fi
  else
    echo "⚠️ No se encontró el archivo de tema de Neovim en $NVIM_THEME_FILE"
  fi
fi
echo ""

"$SCR/chrome.sh" 
"$SCR/terminal.sh" 
# gum confirm "Presiona Enter para salir" > /dev/null

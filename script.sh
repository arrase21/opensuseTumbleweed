#!/usr/bin/env bash
set -Eeuo pipefail

LOG="$HOME/mangowc-install.log"
exec > >(tee -a "$LOG") 2>&1

trap 'echo "❌ Error en línea $LINENO"; exit 1' ERR

### ---------- UI helpers ----------
title(){ echo -e "\n\033[1;35m==> $1\033[0m\n"; }
step(){ echo -e "\033[1;36m[•] $1...\033[0m"; }
ok(){ echo -e "\033[1;32m✔ $1\033[0m"; }

##################################
# DEPENDENCIAS MODULARIZADAS
##################################

core_pkgs="
bc curl wget unzip 7zip findutils git jq inxi xdg-user-dirs xdg-utils
ydotool opi libnotify-tools pavucontrol playerctl pamixer xwayland
wayland-protocols-devel brightnessctl bluez NetworkManager upower
power-profiles-daemon
"

wayland_pkgs="
grim slurp swappy wl-clipboard cliphist waybar hyprlock mako swayidle
mpv mpv-mpris npm-default meson rust cargo SwayNotificationCenter swww 
wlogout nwg-look swaybg polkit-gnome sox ImageMagick
"

desktop_apps_pkgs="
ghostty foot thunar telegram-desktop rofi-wayland
yazi fastfetch fd bat fzf eza fish tmux starship btop
typescript go tree-sitter
"

build_deps="
meson ninja gcc make
"

##################################
# FUNCIONES INSTALL
##################################

add_repositories() {
  title "Adding external repositories"
  step "Adding DankLinux repository"
  if ! zypper lr | grep -q "danklinux"; then
    sudo zypper addrepo https://download.opensuse.org/repositories/home:AvengeMedia:danklinux/openSUSE_Tumbleweed/home:AvengeMedia:danklinux.repo
    ok "DankLinux repo added"
  else
    echo "  ℹ️  DankLinux repo already exists"
  fi
  step "Adding DMS repository"
  if ! zypper lr | grep -q "dms"; then
    sudo zypper addrepo https://download.opensuse.org/repositories/home:/AvengeMedia:/dms/openSUSE_Tumbleweed/home:AvengeMedia:dms.repo
    ok "DMS repo added"
  else
    echo "  ℹ️  DMS repo already exists"
  fi
  
  step "Refreshing repositories"
  sudo zypper refresh
  ok "Repositories refreshed"
}

install_dms() {
  title "Installing DMS (Display Manager Selector)"
  if ! command -v dms >/dev/null 2>&1; then
    sudo zypper install -y dms
    ok "DMS installed"
  else
    echo "  ℹ️  DMS already installed"
  fi
}

install_dependencies() {
  title "Installing dependencies"
  sudo zypper --non-interactive install -y \
    $core_pkgs \
    $wayland_pkgs \
    $desktop_apps_pkgs \
    $build_deps || true
  ok "Dependencies installed"
}

clone_dotfiles() {
  title "Dotfiles"
  mkdir -p "$HOME/repos"
  cd "$HOME/repos"
  if [ ! -d opensuseTumbleweed ]; then
    git clone https://github.com/arrase21/opensuseTumbleweed.git
  else
    git -C opensuseTumbleweed pull --rebase
  fi
  ok "Dotfiles ready"
}

copy_configs() {
  step "Copy configs"
  BASE="$HOME/repos/opensuseTumbleweed"
  mkdir -p "$HOME/.config" "$HOME/.local" "$HOME/Pictures"
  
  # -a = archive (preserva permisos, timestamps, etc)
  # --no-perms = evita problemas de permisos en home
  rsync -a --no-perms "$BASE/.config/" "$HOME/.config/" 2>/dev/null || true
  rsync -a --no-perms "$BASE/.local/" "$HOME/.local/" 2>/dev/null || true
  
  # Carpetas sin punto inicial (verifica que existan primero)
  [ -d "$BASE/.themes" ] && rsync -a --no-perms "$BASE/.themes/" "$HOME/.themes/" 2>/dev/null || true
  [ -d "$BASE/.icons" ] && rsync -a --no-perms "$BASE/.icons/" "$HOME/.icons/" 2>/dev/null || true
  [ -d "$BASE/wallpapers" ] && rsync -a --no-perms "$BASE/wallpapers/" "$HOME/Pictures/wallpapers/" 2>/dev/null || true
  
  ok "Configs copied"
}

setup_xdg_dirs() {
  title "Configurando XDG user directories"
  
  # Actualizar directorios XDG
  xdg-user-dirs-update
  
  # Si tienes un archivo personalizado en tu repo, copiarlo
  if [ -f "$HOME/repos/opensuseTumbleweed/.config/user-dirs.dirs" ]; then
    cp "$HOME/repos/opensuseTumbleweed/.config/user-dirs.dirs" "$HOME/.config/"
    xdg-user-dirs-update
  fi
  
  ok "XDG directories updated"
}

compile_wlsunset() {
  title "Compilando wlsunset"
  cd "$HOME/repos"
  
  if [ ! -d wlsunset ]; then
    step "Clonando wlsunset"
    git clone https://github.com/kennylevinsen/wlsunset
    cd wlsunset
    meson build
    ninja -C build
    sudo ninja -C build install
    ok "wlsunset compiled and installed"
  else
    step "wlsunset ya existe, actualizando"
    cd wlsunset
    git pull
    meson build --wipe 2>/dev/null || meson build
    ninja -C build
    sudo ninja -C build install
    ok "wlsunset updated"
  fi
}

compile_wlr_dpms() {
  title "Compilando wlr-dpms"
  cd "$HOME/repos"
  
  if [ ! -d wlr-dpms ]; then
    step "Clonando wlr-dpms"
    git clone https://git.sr.ht/~dsemy/wlr-dpms
    cd wlr-dpms
    make
    sudo make install
    ok "wlr-dpms compiled and installed"
  else
    step "wlr-dpms ya existe, actualizando"
    cd wlr-dpms
    git pull
    make clean
    make
    sudo make install
    ok "wlr-dpms updated"
  fi
}

install_mangowc_repo() {
  title "Installing Mangowc from unofficial repo"
  
  # Verificar si opi está instalado
  if ! command -v opi >/dev/null 2>&1; then
    step "Instalando opi"
    sudo zypper install -y opi
  fi
  
  # Intentar instalar mangowc con opi
  step "Instalando mangowc (home:mantarimay:sway)"
  if echo -e "1\n1" | opi mangowc 2>/dev/null; then
    ok "Mangowc installed successfully"
  else
    echo "⚠️  OPI falló. Instalación manual requerida."
    echo "    Ejecuta: opi mangowc"
    echo "    Y selecciona: 1 (repo) -> 1 (confirmar)"
  fi
}

install_brave() {
  title "Installing Brave"
  if ! command -v brave-browser >/dev/null; then
    curl -fsS https://dl.brave.com/install.sh -o brave.sh
    sh brave.sh
    rm brave.sh
    ok "Brave installed"
  else
    echo "  ℹ️  Brave already installed"
  fi
}

install_tmux_plugins() {
  title "Tmux plugins"
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  else
    git -C ~/.tmux/plugins/tpm pull
  fi
  ok "Tmux ready"
}

# install_rust_tools() {
#   title "Rust tools"
#   for pkg in wallust gyr satty; do
#     cargo install --list | grep -q "$pkg" || cargo install "$pkg"
#   done
#   ok "Rust tools installed"
# }

install_fonts() {
  title "Nerd Fonts"

  mkdir -p "$HOME/.local/share/fonts"
  cd "$HOME/.local/share/fonts"
  for font in JetBrainsMono VictorMono; do
    wget -q -O "$font.zip" \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip"
    unzip -o "$font.zip" -d "$font"
    rm "$font.zip"
  done

  fc-cache -fv
  ok "Fonts installed"
}

setup_android_mtp() {
  title "Android auto-mount"

  sudo usermod -aG fuse "$USER"
  sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

  USER_NAME=$(logname)
  HOME_DIR=$(eval echo "~$USER_NAME")

  sudo tee /etc/udev/rules.d/99-android-mtp.rules >/dev/null <<EOF
ACTION=="add", SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", \
RUN+="/usr/bin/sudo -u $USER_NAME $HOME_DIR/.local/bin/mtp-auto-mount-udev.sh mount"

ACTION=="remove", SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", \
RUN+="/usr/bin/sudo -u $USER_NAME $HOME_DIR/.local/bin/mtp-auto-mount-udev.sh umount"
EOF

  sudo udevadm control --reload-rules
  sudo udevadm trigger
  ok "Android mount ready"
}

##################################
# MAIN
##################################

main() {
  clear
  title "Mangowc Installer"

  add_repositories
  install_dms
  install_dependencies
  clone_dotfiles
  copy_configs
  setup_xdg_dirs
  compile_wlsunset
  compile_wlr_dpms
  install_mangowc_repo
  install_brave
  install_tmux_plugins
  # install_rust_tools
  install_fonts
  setup_android_mtp

  title "INSTALL COMPLETE"
  echo "👉 Restart session recommended"
  echo "📄 Log saved at: $LOG"
}

main "$@"

#!/usr/bin/env bash
set -e

title() {
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 212 --border double --margin "1 2" --padding "1 3" "$1"
  else
    echo -e "\n\e[1;35m==> $1\e[0m\n"
  fi
}

step() {
  if command -v gum >/dev/null 2>&1; then
    gum spin --spinner dot --title "$1" -- sleep 1
  else
    echo -e "\e[1;36m[+] $1...\e[0m"
    sleep 1
  fi
}

success() {
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 46 "✅ $1"
  else
    echo -e "\e[1;32m✅ $1\e[0m"
  fi
}

# --- Inicio ---
clear
title "Installing  Mangowc  environment - openSUSE Tumbleweed"

# --- Dependencias base ---
title "Installing dependencies"
sudo zypper --non-interactive install -y \
  bc curl cliphist findutils gawk git go grim gvfs gvfs-backends \
  ImageMagick inxi jq kitty libnotify-tools nano openssl pamixer \
  pavucontrol playerctl polkit-gnome python312-requests python312-pip \
  python312-pyquery qt5ct qt6ct qt6-svg-devel rofi-wayland slurp swappy \
  SwayNotificationCenter swww unzip wget wayland-protocols-devel \
  wl-clipboard xdg-user-dirs xdg-utils xwayland brightnessctl btop cava \
  fastfetch mousepad mpv mpv-mpris nvtop qalculate-gtk ydotool waybar \
  loupe gnome-system-monitor thunar hyprlock opi typescript npm meson \
  gjs-devel gtk3-devel gtk-layer-shell-devel wlogout upower NetworkManager \
  libdbusmenu-gtk3-4 swayidle scdoc libpulse-devel rust cargo sox neovim \
  ghostty foot fish tmux starship bluez mako simple-mtpfs fuse fd bat fzf \

# --- Configuración de usuario ---
step "Updates user directory"
xdg-user-dirs-update

mkdir -p "$HOME/repos" "$HOME/.config" "$HOME/.local/share/fonts" "$HOME/.local/bin"

step "Cloning dot-files"
cd "$HOME/repos"
if [ ! -d dot-files ]; then
  git clone https://github.com/arrase21/dot-files
else
  git -C dot-files pull
fi

step "Copy config & resources"
cp -r "$HOME/repos/dot-files/.config/"* "$HOME/.config/"
cp -r "$HOME/repos/dot-files/wallpapers/"* "$HOME/Pictures/" 2>/dev/null || true
cp -r "$HOME/repos/dot-files/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
cp -r "$HOME/repos/dot-files/.local/"* "$HOME/.local/" 2>/dev/null || true

# --- Instalación Brave ---
step "Installing Brave Browser"
if ! command -v brave-browser >/dev/null 2>&1; then
  curl -fsS https://dl.brave.com/install.sh | sh
fi

# --- Herramientas Rust ---
title "Installing Rust Tools"
for pkg in wallust gyr; do
  if ! cargo install --list | grep -q "$pkg"; then
    cargo install "$pkg" || true
  fi
done

# --- Compilar utilidades ---
cd "$HOME/repos"
if [ ! -d wlsunset ]; then
  git clone https://github.com/kennylevinsen/wlsunset
  cd wlsunset
  meson build
  ninja -C build
  sudo ninja -C build install
fi

cd "$HOME/repos"
if [ ! -d wlr-dpms ]; then
  git clone https://git.sr.ht/~dsemy/wlr-dpms
  cd wlr-dpms
  make
  sudo make install
fi

# --- OPI Installing Mangowc ---
title "Installing Mangowc not oficial repo (home:mantarimay:sway)"
if ! command -v opi >/dev/null 2>&1; then
  sudo zypper install -y opi
fi

opi mangowc <<< "1
1
" || echo "⚠️ Instalación manual requerida si OPI falla."

# Dependencias extra
sudo zypper install -y scenefx-devel wlroots-devel || true

# --- Enlace de tema para btop ---
step "Btop theme"
mkdir -p "$HOME/.config/btop/themes"
ln -sf "$HOME/.config/current/theme/btop.theme" "$HOME/.config/btop/themes/current.theme"

# --- Fonts ---
title "Installing Nerd Fonts"
cd "$HOME/.local/share/fonts" || exit
for font in JetBrainsMono VictorMono; do
  echo "🧩 Instalando $font Nerd Font..."
  wget -O "$font.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip"
  unzip -o "$font.zip" -d "$font"
  rm "$font.zip"
done
fc-cache -fv
echo "✅ Fonts installed successfully."

#-- Android Yazi
title "Add User to fuse using android phone and yazi"
sudo usermod -aG fuse $USER
sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

step "udev rule for MTP"
sudo tee /etc/udev/rules.d/99-android-mtp.rules > /dev/null << 'EOF'
ACTION=="add", SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", \
    RUN+="/usr/bin/sudo -u arrase /home/arrase/.local/bin/mtp-auto-mount-udev.sh mount"

ACTION=="remove", SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", \
    RUN+="/usr/bin/sudo -u arrase /home/arrase/.local/bin/mtp-auto-mount-udev.sh umount"
EOF

step "Reload udev"
sudo udevadm control --reload-rules
sudo udevadm trigger
success "Android auto-mount" 

success "Complete Instalation  🎉"
success "Reload your session"

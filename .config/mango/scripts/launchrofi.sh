#!/usr/bin/env bash

cd ~
# Usage Information
usage() {
    echo -e "\n Usage:
      --menu                            : Displays a custom menu with multiple options. \n
      --sys_menu                        : Displays system menu. \n
      --screenshot_menu                 : Displays system menu. \n
      "
    exit 1
}


custom_menu() {
    options=" \n \n \n \n\n\n"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/submenu.rasi -dmenu  -theme-str 'mainbox {children: ["listview" ];}' -p "")
    case $chosen in
        " ")
            rofi -show drun
            ;;
        " ")
            pcmanfm-qt
            ;;
        "")
            session_options
            ;;
        " ")
            foot
            ;;
        " ")
            bash ~/scripts/open-browser
            ;;
        "")
            bash ~/launchrofi.sh -sm
            ;;
        "")
            manual_func
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

session_options() {
    options="  Shutdown\n  Reboot\n  Lock\n󰍃  Logout"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 4;}' -theme-str 'window {width: 285px;}' -theme-str 'mainbox {children: ["listview" ];}' -p "")
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "  Shutdown")
            systemctl poweroff
            ;;
        "  Reboot")
            systemctl reboot
            ;;
        "  Lock")
            hyprlock & disown
            ;;
        "󰍃  Logout")
            hyprctl dispatch exit && sleep 1 && loginctl terminate-user "$USER"
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

default_apps_func() {
    options="󰌍\n  Browser\n󰠮  Editor"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")
    case $chosen in
        "󰌍")
            settings_func
            ;;
        "  Browser")
            bash ~/.config/mango/scripts/set-default-browser
            default_apps_func
            ;;
        "󰠮  Editor")
            bash ~/config/mango/scripts/set-default-editor
            default_apps_func
            ;;
        *)
            ;;
    esac
}
settings_func() {
    # Menu options displayed in rofi
    options="󰌍\n  Reload Shell\n  Set Default Apps\n󰌁  Customize Rice\n󰚰  Update Config"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "  Reload Shell")
            pkill waybar 
            waybar -c ~/.config/mango/waybar/config -s ~/.config/mango/waybar/style.css >/dev/null 2>&1 &
            makoctl reload   
            settings_func
            ;;
        "  Set Default Apps")
           default_apps_func 
            ;;
        "󰌁  Customize Rice")
            customize_func
            ;;
        "󰚰  Update Config")
            foot --override=colors.alpha=1 --app-id=Update -e bash ~/Dotfiles/bin/update_binarydots
            cd ~
            settings_func
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}


customize_func() {
    # Menu options displayed in rofi
    options="󰌍\n  Set Style Locks\n  Widgets Settings\n  Wallpapers\n󰌁  Themes"
    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")
    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            settings_func
            ;;
        "  Set Style Locks")
            lock_menu
            ;;
        "󰌁  Themes")
            theme_menu
            ;;
        "  Wallpapers")
            set_wallpaper
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}


maintain_menu() {
    options="󰌍\n󰃢  Clear Cache\n󱘡  Clear Clipboard"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "󰃢  Clear Cache")
         	find ~/.cache -mindepth 1 -maxdepth 1 \
         	  ! -name "spotify" \
         	  ! -name "cliphist" \
         	  ! -name "paru" \
         	  ! -name "mcpelauncher-webview"\
         	  ! -name "pip" \
         	  ! -name "rofi-entry-history.txt" \
         	  ! -name "Hyprland Polkit Agent" \
         	  ! -name "spotube" \
         	  ! -name "oss.krtirtho.spotube" \
         	  -exec rm -rf {} + >/dev/null 2>&1 & disown
            maintain_menu
            ;;
        "󱘡  Clear Clipboard")
            rm -rf ~/.cache/cliphist >/dev/null 2>&1 & disown
            maintain_menu
            ;; 
        *)
            echo "No option selected"
            ;;
    esac
}

manual_func() {
    options="󰌍\n  Keybinds"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")
    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "  Keybinds")
            rofi -config $HOME/.config/mango/rofi/browser.rasi -show drun -dmenu -i -p  ' ' < ~/.config/mango/scripts/help.txt
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

screenshot_func() {
    options="󰌍\n  Screenshots\n  Fullscreen\n  Selection\n  Now"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "  Screenshots")
            foot -e yazi ~/Pictures/Screenshots/
            ;;
        "  Fullscreen")
            bash ~/screenshot.sh fullscreen
            ;;
        "  Selection")
            bash ~/screenshot.sh region
            ;;
        "  Now")
            bash ~/screenshot.sh instant
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

connections_func() {
    options="󰌍\n󰤨  WiFi\n  Bluetooth"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "󰤨  WiFi") 
            bash ~/scripts/rofi-wifi
            ;;
        "  Bluetooth")
            bash ~/scripts/rofi-bluetooth 
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

misc_func() {
    options="󰌍\n  Toggle DND\n  Toggle Cafein\n󰈈  Toggle Eye Saver"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "  Toggle DND")
            makoctl mode -t dnd
            misc_func
            ;;
        "  Toggle Cafein")
            bash $HOME/scripts/cafein toggle -n
            misc_func
            ;;
        "󰈈  Toggle Eye Saver")
            bash $HOME/Dotfiles/scripts/toggle-sunset
            misc_func
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

system_menu() {
    options="  Connections\n󰃢  Maintaining\n󰅇  Clipboard\n󰄀  Screenshot\n󰐱  Miscellaneous\n  Session Options\n  Manual\n󰌽  Themes\n  Wallpapers\n  Settings"
    # chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 14;}' -theme-str 'mainbox {children: ["inputbar","listview" ];}'  -p "")
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")
    case $chosen in
        "  Connections")
            connections_func
            ;;
        "󰃢  Maintaining")
            maintain_menu
            ;;
        "󰅇  Clipboard")
            bash ~/.config/mango/scripts/ClipManager.sh
            ;;
        "󰄀  Screenshot")
            screenshot_func 
            ;;
        "󰐱  Miscellaneous")
            misc_func 
            ;;
        "  Session Options")
            session_options
            ;;
        "  Manual")
            manual_func
            ;;
        "󰌽  Themes")
            theme_menu
            ;;
        "  Wallpapers")
            set_wallpaper
            ;;
        "  Settings")
            settings_func
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}
set_wallpaper() {
  SCR="$HOME/.config/mango/scripts"
  "$SCR/WallpaperSelect.sh"
    # # Prompt user to choose an option
    # chosen=$(python3 ~/scripts/wallpapers.py echoImageNames | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'mainbox {children: ["inputbar","listview" ];}'  -p "")
    # # Execute the corresponding command based on the selected option
    # echo $chosen
    # python3 ~/scripts/wallpapers.py changeWallpaper $chosen
}

theme_menu() {
   THEME_DIR="$HOME/.config/themes"
    THEMES=$(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
    chosen=$(echo -e "󰌍\n$THEMES" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "" -theme-str 'listview {lines: 10;}')
    if [[ -z "$chosen" ]]; then 
        exit 1
    elif [[ "$chosen" = "󰌍" ]];then
        system_menu
        return
    fi
    systemd-run --user --scope \
        --setenv=WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
        --setenv=XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        "$HOME/.config/mango/scripts/themes.sh" -c "$chosen"
}
# Check for flags and validate input
if [[ $# -ne 1 ]]; then
    if [[ "$1" != "--conf_launcher" ]]; then
        usage 
    fi
fi
# Execute the appropriate function based on the provided flag
case "$1" in
    # --drun|-d)
    #     drun_launcher
    #     ;;
    # --window|-w)
    #     rofi \
    #     -show window \
    #     -theme ~/.config/rofi/window.rasi
    #     ;;
    #
    # --run|-r)
    #     run_launcher
    #     ;;
    --menu|-m)
        custom_menu
        ;;
    --power-menu|-pm)
        session_options
        ;;
    --widget_settings|-ws)
    	widget_settings
    	;;
     --rice_settings|-rs)
     	settings_func
     	;;
     --system_menu|--sys_menu|-sm)
     	system_menu
     	;;
    --screenshot_menu|--ss_menu|-ss)
     	screenshot_func
     	;;
    --conf_launcher|-cl)
        conf_launcher "$2" "$3"
        ;;
    *)
        usage
        ;;
esac

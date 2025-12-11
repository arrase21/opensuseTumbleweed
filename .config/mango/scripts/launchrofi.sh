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

lock_menu() {
    # Menu options displayed in rofi
    cd ~/scripts/
    options=$(python3 ~/scripts/style_lock.py dmenu)
    # Prompt user to coose an option
    chosen=$(echo -e "󰌍\n$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "" -theme-str 'listview {lines: 4;}')
    cd ~
    if [[ -z "$chosen" ]]; then 
        exit 1
    elif [[ "$chosen" = "󰌍" ]];then
        customize_func
    else
        cd ~/scripts
        argument="${chosen:3}"
        python3 style_lock.py "$argument"
        lock_menu
    fi
   $HOME/.config/mango/scripts/themes.sh -c $chosen 
}

# Function: Custom Menu
custom_menu() {
    # Menu options displayed in rofi
    options=" \n \n \n \n\n\n"
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/submenu.rasi -dmenu  -theme-str 'mainbox {children: ["listview" ];}' -p "")
    # Execute the corresponding command based on the selected option
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
    # Menu options displayed in rofi
    options="  Shutdown\n  Reboot\n  Lock\n󰍃  Logout"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 4;}' -theme-str 'window {width: 285px;}' -theme-str 'mainbox {children: ["listview" ];}' -p "")
    # Execute the corresponding command based on the selected option
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


widget_settings() {
    # Menu options displayed in rofi
    options="󰌍\n  Desk Clock\n  Change Stats\n  Change Music\n  Reload Widgets\n  Initalize"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            customize_func
            ;;
        "  Desk Clock")
            bash ~/.config/hypr/scripts/widgets.sh three
            bash ~/.config/hypr/scripts/widgets.sh r >/dev/null 2>&1 & disown
            widget_settings
            ;;
        "  Change Stats")
            bash ~/.config/hypr/scripts/widgets.sh one
            bash ~/.config/hypr/scripts/widgets.sh r >/dev/null 2>&1 & disown
            widget_settings
            ;;
        "  Change Music")
            bash ~/.config/hypr/scripts/widgets.sh two
            bash ~/.config/hypr/scripts/widgets.sh r >/dev/null 2>&1 & disown
            widget_settings
            ;;
        "  Reload Widgets")
            bash ~/.config/hypr/scripts/widgets.sh r >/dev/null 2>&1 & disown
            widget_settings
            ;;
        "  Initalize Widgets")
            bash ~/.config/hypr/scripts/widgets.sh r >/dev/null 2>&1 & disown
            widget_settings
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}


settings_func() {
    # Menu options displayed in rofi
    options="󰌍\n  Activate Linux\n  Reload Shell\n  Set Default Apps\n󰌁  Customize Rice\n󰚰  Update Binarydots"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "  Activate Linux")
            bash ~/.config/hypr/scripts/widgets.sh four
            bash ~/.config/hypr/scripts/widgets.sh r >/dev/null 2>&1 & disown
            settings_func
            ;;
        "  Reload Shell")
            pkill waybar 
            waybar >/dev/null 2>&1 & disown
            bash ~/.config/hypr/scripts/widgets.sh r >/dev/null 2>&1 & disown
            makoctl reload   
            settings_func
            ;;
        "  Set Default Apps")
           default_apps_func 
            ;;
        "󰌁  Customize Rice")
            customize_func
            ;;
        "󰚰  Update Binarydots")
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
        "  Widgets Settings")
            widget_settings
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

set_wallpaper() {
  SCR="$HOME/.config/mango/scripts"
  "$SCR/WallpaperSelect.sh"
    # # Prompt user to choose an option
    # chosen=$(python3 ~/scripts/wallpapers.py echoImageNames | rofi -config ~/.config/rofi/sysmenu.rasi -dmenu -theme-str 'mainbox {children: ["inputbar","listview" ];}'  -p "")
    # # Execute the corresponding command based on the selected option
    # echo $chosen
    # python3 ~/scripts/wallpapers.py changeWallpaper $chosen
}

maintain_menu() {
    # Menu options displayed in rofi
    options="󰌍\n󰃢  Clear Cache\n󱘡  Clear Clipboard"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")

    # Execute the corresponding command based on the selected option
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
    # Menu options displayed in rofi
    options="󰌍\n  Keybinds"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")

    # Execute the corresponding command based on the selected option
    case $chosen in
        "󰌍")
            system_menu
            ;;
        "  Keybinds")
            rofi -dmenu -theme-str 'window {width: 52%;}' -dmenu -theme-str 'listview {lines: 14;}' -i -p ' ' < ~/.config/hypr/scripts/help.txt
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}

screenshot_func() {
    # Menu options displayed in rofi
    options="󰌍\n  Screenshots\n  Fullscreen\n  Selection"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")

    # Execute the corresponding command based on the selected option
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
        *)
            echo "No option selected"
            ;;
    esac
}

connections_func() {
    # Menu options displayed in rofi
    options="󰌍\n󰤨  WiFi\n  Bluetooth"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")

    # Execute the corresponding command based on the selected option
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
    # Menu options displayed in rofi
    options="󰌍\n  Toggle DND\n  Toggle Cafein\n󰈈  Toggle Eye Saver"

    # Prompt user to choose an option
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 6;}' -p "")

    # Execute the corresponding command based on the selected option
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
    # Menu options displayed in rofi
    options="  Connections\n󰃢  Maintaining\n󰅇  Clipboard\n󰄀  Screenshot\n󰐱  Miscellaneous\n  Session Options\n  Manual\n󰌁  Themes\n  Settings\n  Update System\n󰌁 Wallpapers"

    # Prompt user to choose an option
    # chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -theme-str 'listview {lines: 14;}' -theme-str 'mainbox {children: ["inputbar","listview" ];}'  -p "")
    chosen=$(echo -e "$options" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "")
    # Execute the corresponding command based on the selected option
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
        "  Update System")
            foot --override=colors.alpha=1 --app-id=Update -e bash ~/Dotfiles/bin/update
            ;;
        "󰌁  Themes")
            theme_menu
            ;;
        "  Wallpapers")
            set_wall
            ;;
        "  Settings")
            settings_func
            ;;
        "  Manual")
            manual_func
            ;;
        *)
            echo "No option selected"
            ;;
    esac
}
set_wall() {
  SCR="$HOME/.config/mango/scripts"
  "$SCR/WallpaperSelect.sh"
}


theme_menu() {
   THEME_DIR="$HOME/.config/themes"

    # Menu options displayed in rofi
    THEMES=$(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
    # Prompt user to choose an option
    chosen=$(echo -e "󰌍\n$THEMES" | rofi -config ~/.config/mango/rofi/sysmenu.rasi -dmenu -p "" -theme-str 'listview {lines: 10;}')
    
    if [[ -z "$chosen" ]]; then 
        exit 1
    elif [[ "$chosen" = "󰌍" ]];then
        system_menu
        return
    fi
    
    # Usar systemd-run para ejecutar en un scope completamente separado
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

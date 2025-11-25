if status is-interactive
    set fish_greeting
    
    # Paths
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/.spicetify
    fish_add_path $HOME/go/bin
    
    # Terminal settings
    set -x TERM xterm-256color
    set -x COLORTERM truecolor
    
    # Aliases básicos
    alias ls 'eza --icons'
    alias la 'eza --icons -A'
    alias ll 'eza --icons -l'
    alias lla 'eza --icons -lA'
    alias lt 'eza --icons --tree --level=2'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    
    # Aliases de aplicaciones
    alias q 'qs -c ii'
    alias v 'nvim'
    alias t 'tmux'
    alias g 'git'
    
    # Aliases de navegación
    alias cw 'cd /home/arrase/workspaces/'
    alias .. 'cd ..'
    alias ... 'cd ../..'
    alias .... 'cd ../../..'
    
    # Aliases de servicios
    alias mys 'sudo systemctl start mysqld'
    alias mysk 'sudo systemctl stop mysqld'
    alias htp 'sudo systemctl start httpd'
    alias htpk 'sudo systemctl stop httpd'
    
    # Aliases de Python
    alias pv 'python -m venv .env'
    alias pva 'source .env/bin/activate.fish'
    alias pga 'source pgadmin4/bin/activate.fish'
end

# ------------------------------
# Yazi con autocd (mantener sin alias)
# ------------------------------
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"
        if test -n "$cwd" -a "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
    end
    rm -f -- "$tmp"
end

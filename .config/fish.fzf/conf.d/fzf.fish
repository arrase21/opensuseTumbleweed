# fzf.fish is only meant to be used in interactive mode
if not status is-interactive
    exit
end

# FZF keybindings (modernos) ================================
fzf --fish | source

# cd ** → selector con fzf ==================================
function __fzf_cd_widget
    if test (count $argv) -eq 1 -a "$argv" = "**"
        set dir (fd -t d . | fzf --preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || tree -C {} | head -200')
        test -n "$dir"; and builtin cd "$dir"; and commandline -f repaint
        return
    end
    builtin cd $argv
end

# Sobrescribir cd solo para el pattern ** ====================
function cd
    __fzf_cd_widget $argv
end

# Alt-c → cambiar directorio desde HOME ======================
function fzf_alt_c
    set -l dir (fd -t d . $HOME | fzf --preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || tree -C {} | head -200')
    test -n "$dir"; and builtin cd "$dir"; and commandline -f repaint
end

bind \ec fzf_alt_c

# Ctrl+r → historial de comandos =============================
function fzf_history
    history | fzf --tac --no-sort | read -l result
    test -n "$result"; and commandline -r "$result"
end

bind \cr fzf_history

# Ctrl+f → buscar archivos y abrir ===========================
function fzf_file_widget
    set -l file (fd -t f | fzf --preview 'bat --color=always --style=numbers {}')
    test -n "$file"; and commandline -i "$file"
end

bind \cf fzf_file_widget

# Ctrl+t → abrir archivo con nvim
# Ctrl+f → pegar ruta de archivo
function fzf_open
    set -l file (fd -t f | fzf --preview 'bat --color=always --style=numbers {}')
    test -n "$file"; and nvim "$file"; and commandline -f repaint
end

function fzf_paste
    set -l file (fd -t f | fzf --preview 'bat --color=always --style=numbers {}')
    test -n "$file"; and commandline -i "$file"
end

bind \ct fzf_open    # Ctrl+t = abrir
bind \cf fzf_paste   # Ctrl+f = pegar ruta

# Opciones globales FZF ======================================
set -x FZF_DEFAULT_OPTS '
    --height=40%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt="❯ "
    --pointer="▶"
    --marker="✓"
    --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
    --color=fg+:#c0caf5,bg+:#283457,hl+:#7dcfff
    --color=info:#7dcfff,prompt:#7dcfff,pointer:#7dcfff
    --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
'

set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'

set -x FZF_CTRL_T_OPTS \
    "--preview 'bat -n --color=always {} 2>/dev/null || cat {}'" \
    "--bind 'ctrl-/:toggle-preview'"

set -x FZF_CTRL_R_OPTS \
    "--preview 'echo {}' --preview-window down:3:hidden:wrap" \
    "--bind 'ctrl-/:toggle-preview'"

set -x FZF_ALT_C_OPTS \
    "--preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || tree -C {} | head -200'"

# Integración con bat para previews =================================
set -x BAT_THEME 'Catppuccin'

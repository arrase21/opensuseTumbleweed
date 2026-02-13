# fzf.fish is only meant to be used in interactive mode. If not in interactive mode and not in CI, skip the config to speed up shell startup
if not status is-interactive && test "$CI" != true
    exit
end

# Because of scoping rules, to capture the shell variables exactly as they are, we must read
# them before even executing _fzf_search_variables. We use psub to store the
# variables' info in temporary files and pass in the filenames as arguments.
# This variable is global so that it can be referenced by fzf_configure_bindings and in tests
set --global _fzf_search_vars_command '_fzf_search_variables (set --show | psub) (set --names | psub)'


# Install the default bindings, which are mnemonic and minimally conflict with fish's preset bindings
fzf_configure_bindings

# Doesn't erase autoloaded _fzf_* functions because they are not easily accessible once key bindings are erased
function _fzf_uninstall --on-event fzf_uninstall
    _fzf_uninstall_bindings

    set --erase _fzf_search_vars_command
    functions --erase _fzf_uninstall _fzf_migration_message _fzf_uninstall_bindings fzf_configure_bindings
    complete --erase fzf_configure_bindings

    set_color cyan
    echo "fzf.fish uninstalled."
    echo "You may need to manually remove fzf_configure_bindings from your config.fish if you were using custom key bindings."
    set_color normal
end

function fzf_alt_c
    set -l dir (fd -t d . $HOME | fzf --preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || tree -C {} | head -200')
    test -n "$dir"; and builtin cd "$dir"; and commandline -f repaint
end

bind \ec fzf_alt_c

set -x FZF_DEFAULT_OPTS '
    --height=70%
    --layout=reverse
    --border=rounded
    --info=inline
    --prompt="❯ "
    --pointer="▶"
    --marker="✓"
'

bind -e \cv

function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source
    set -x STARSHIP_CONFIG ~/.config/starship/starship.toml
    # Aliases
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'

    # aliases
    alias y "yazi"
    alias v "nvim"
    alias la "ls -A"
    alias ll "ls -l"
    alias lla "ll -A"
    alias t "tmux"
    alias g git
    alias cw "cd /home/arrase/workspaces/"
    alias mys "sudo systemctl start mysqld"
    alias mysk "sudo systemctl stop mysqld"
    alias htp "sudo systemctl start httpd"
    alias htpk "sudo systemctl stop httpd"
    alias pv "python -m venv .env"
    alias pva "source .env/bin/activate.fish"
    alias pga "source pgadmin4/bin/activate.fish"
    
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/.spicetify
    fish_add_path $HOME/go/bin

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

end

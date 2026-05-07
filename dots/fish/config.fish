set --global eza_run_on_cd true
set --global zoxide_cmd_override cd
set --global bat_ignore_man true

set --global EDITOR nvim
function edit
    $EDITOR $argv
end

alias box distrobox

function box-backup --description "Backup the current toolbox container to a tarball"
  podman container commit -p toolbox toolbox-backup
  podman save toolbox-backup:latest | bzip2 > ~/.config/distrobox/toolbox-backup.tar.bz
end

function box-restore --description "Restore the toolbox container from a tarball"
  podman load < ~/.config/distrobox/toolbox-backup.tar.bz
end

alias gg lazygit
alias dd lazydocker
# fzf over files and open result in nvim
alias f "fd --type f | fzf | sed 's/\ /\\ /g' | xargs nvim"

# hydro prompt
set --global fish_prompt_pwd_dir_length 999
set --global hydro_multiline true

set --local symbol " "
if set -q DISTROBOX_ENTER_PATH
    set --global hydro_symbol_prompt "$symbol [distrobox] "
else
    set --global hydro_symbol_prompt "$symbol"
end

set --global hydro_symbol_start "\n"
set --global hydro_symbol_git_dirty "  "
set --global hydro_symbol_git_ahead " "
set --global hydro_symbol_git_behind " "

# catppuccin
set --global hydro_color_prompt f9e2af
set --global hydro_color_error f38ba8
set --global hydro_color_pwd 89b4fa
set --global hydro_color_git 94e2d5
set --global hydro_color_duration cba6f7

# fish
set --global fish_greeting ""
set --global fish_key_bindings fish_default_key_bindings

bind ctrl-f accept-autosuggestion
bind ctrl-g nextd-or-forward-word
bind ctrl-b backward-kill-word

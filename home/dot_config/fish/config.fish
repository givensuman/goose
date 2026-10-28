if status is-interactive
    set --global eza_run_on_cd true
    set --global zoxide_cmd_override cd
    set --global bat_ignore_man true
end

set --global EDITOR nvim
function edit
    $EDITOR $argv
end

if status is-interactive
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

    set --global hydro_color_prompt f9e2af
    set --global hydro_color_error f38ba8
    set --global hydro_color_pwd 89b4fa
    set --global hydro_color_git 94e2d5
    set --global hydro_color_duration cba6f7
end

set --global fish_greeting ""
set --global fish_key_bindings fish_default_key_bindings

if status is-interactive
    # Aliases
    alias dd lazydocker
    alias f 'fd --type f | fzf | sed '\''s/ /\ /g'\'' | xargs $EDITOR'
    alias gg lazygit

    # Key bindings
    bind ctrl-f accept-autosuggestion
    bind ctrl-g nextd-or-forward-word
    bind ctrl-b backward-kill-word

    # fzf
    fzf --fish | source

    # ghostty
    if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
    end

    # fisher
    if functions --query fisher
        fisher --version >/dev/null
    end

    # zellij
    if type -q zellij
      if not set -q ZELLIJ
        eval (zellij setup --generate-auto-start fish | string collect)
      end
    end
end

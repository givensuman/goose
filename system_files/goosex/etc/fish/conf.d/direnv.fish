# Hook direnv into interactive fish for every user (bash/zsh: profile.d/direnv.sh).
if status is-interactive; and type -q direnv
    direnv hook fish | source
end

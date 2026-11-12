if [ -n "${BASH_VERSION:-}" ] && [ -t 0 ] && command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
elif [ -n "${ZSH_VERSION:-}" ] && [ -t 0 ] && command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

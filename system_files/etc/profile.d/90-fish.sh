# Use fish as the interactive shell without changing the login shell,
# keeping bash usable for scripts and as a fallback.
# Set GOOSE_NO_FISH=1 to opt out for a session.
if [ -n "${BASH_VERSION:-}" ] && [[ $- == *i* ]] \
    && [ -z "${GOOSE_NO_FISH:-}" ] && [ -z "${BASH_EXECUTION_STRING:-}" ] \
    && command -v fish >/dev/null 2>&1 \
    && [ "$(cat "/proc/${PPID}/comm" 2>/dev/null)" != "fish" ]; then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec fish ${LOGIN_OPTION}
fi

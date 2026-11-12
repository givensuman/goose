if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]] && [[ -z ''${BASH_EXECUTION_STRING} ]]; then
  shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
  SHELL=$(which fish)
  exec fish ${LOGIN_OPTION}
fi
